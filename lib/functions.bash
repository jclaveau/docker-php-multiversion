#!/bin/bash

function in_docker_container() {
    if [[ -f /.dockerenv ]] || grep -Eq '(lxc|docker)' /proc/1/cgroup; then
        return 0
    else
        return 1
    fi
}

function extract_hosts() {
    cat /etc/hosts | grep '172.17.'
}

function extract_first_host() {
    extract_hosts | awk '{ print $2}'
}

function extract_phpmv_hosts() {
    extract_hosts | awk '$2 ~ /^phpmv_.+/ { print $2}'
}

function in_phpmv_container() {
    if in_docker_container ; then
        phpmv_host=$(extract_phpmv_hosts)
        # echo "phpmv_host: $phpmv_host"
        if [ -z "$phpmv_host" ]; then
            return 1
        else
            return 0
        fi
    else
        return 1
    fi
}

function running_from_sibling() {
    if ! in_phpmv_container && in_docker_container ; then
        return 0
    else
        return 1
    fi
}

function install_docker_if_missing() {
    local docker_path docker_installed
    docker_path=$(command -v docker || echo "") # command -v docker fails under shellspec if PATH=""
    if [ -z "$docker_path" ]; then
        echo "docker not installed"
        # echo $docker_path
        read -p "Do you want to install docker? " -n 1 -r
        # echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo "sudo apt-get install docker.io"

            docker_installed=$(sudo apt-get install docker.io 2> /dev/null || (echo "failed"))
            if [ "$docker_installed" == "failed" ]; then
                echo "Unable to launch docker installation. Please do it manually."
                exit
            fi
        else
            echo "Docker.io is required"
            exit
        fi
    fi
}

function replace_slashes_by_underscores() {
    # shellcheck disable=SC2001
    echo "$1" | sed "s|[^[:alpha:].-]|_|g"
}

function run_docker() {
    local lib_volume_option docker_image_version

    if ! docker ps -a | grep -q "$CONTAINER_NAME$"
    then
        if [ -z "${PHP_MULTIVERSION_IMAGE:-}" ]; then
            # docker_image_version='0.5.3'
            docker_image_version='latest'
        else
            docker_image_version=$PHP_MULTIVERSION_IMAGE
        fi

        volumes_option=''
        if running_from_sibling; then
            # this is what happends in Travis
            HOST_SIBLING_NAME="$(extract_first_host)"
            # echo "$HOST_SIBLING_NAME"
            
            # HOME_VOLUME="phpmv_"$HOST_SIBLING_NAME"_$(replace_slashes_by_underscores "$HOME")"
            # docker volume create --name $HOME_VOLUME
            HOME_VOLUME="$HOME"
            ETC_VOLUME="phpmv_"$HOST_SIBLING_NAME"_$(replace_slashes_by_underscores "/etc")"
            docker volume create --name $ETC_VOLUME > /dev/null
            
            LIBRARY_VOLUME="phpmv_"$HOST_SIBLING_NAME"_$(replace_slashes_by_underscores "$LIBRARY_DIR")"
            docker volume create --name $LIBRARY_VOLUME > /dev/null

            # run copier container
            copier_cmd="docker run \
                -d \
                --rm \
                --name=phpmv_copier \
                --volume=$ETC_VOLUME:/volume_etc:rw \
                --volume=$LIBRARY_VOLUME:/volume_pwd:rw \
                phusion/baseimage:master /sbin/my_init"

            docker kill 'phpmv_copier' 2>&1 /dev/null
            copier_id="$(eval "$copier_cmd")"

            if [ -z "$copier_id" ]; then
                echo "Unable to start the copier container"
                exit
            fi


            docker cp "$HOST_SIBLING_NAME":/etc/passwd /tmp/etc_passwd
            docker cp "$HOST_SIBLING_NAME":/etc/group  /tmp/etc_group
            docker cp "$HOST_SIBLING_NAME":/etc/passwd /tmp/etc_shadow
            docker cp "$HOST_SIBLING_NAME":"$LIBRARY_DIR" /tmp/volume_pwd
            docker cp /tmp/etc_passwd "$copier_id":/volume_etc/passwd
            docker cp /tmp/etc_group  "$copier_id":/volume_etc/group
            docker cp /tmp/etc_shadow "$copier_id":/volume_etc/shadow
            
            docker cp /tmp/volume_pwd "$copier_id":/
            # SUDOERS_VOLUME="phpmv_$(replace_slashes_by_underscores "/etc/sudoers.d")"

            etc_volume_option="--volume=$ETC_VOLUME:/volume_etc:ro"
        else
            etc_volume_option=("--volume=/etc/sudoers.d:/etc/sudoers.d:ro")
            etc_volume_option+=("--volume=/etc/group:/etc/group:ro")
            etc_volume_option+=("--volume=/etc/passwd:/etc/passwd:ro")
            etc_volume_option+=("--volume=/etc/shadow:/etc/shadow:ro")
            etc_volume_option="$(join_by ' ' "${etc_volume_option[@]}")"
                # --volume="$HOME_VOLUME"/.composer:"$HOME"/.composer:rw 
            HOME_VOLUME="$HOME"
            LIBRARY_VOLUME="$LIBRARY_DIR"
        fi

        # echo "Running new docker jclaveau/php-multiversion for $(pwd)"
        if [ "$HOME" != "$LIBRARY_DIR" ]; then
            pwd_volume_option="--volume $LIBRARY_VOLUME:$LIBRARY_DIR"
        else
            pwd_volume_option=''
        fi

        if [ -d "$LIBRARY_DIR/log" ]; then
            log_volume_option="--volume=$LIBRARY_DIR/log:/host_log"
        else
            log_volume_option=''
        fi

        if [ -d "$LIBRARY_DIR/etc" ]; then
            custom_etc_volume_option="--volume=$LIBRARY_DIR/etc:/custom_etc"
        else
            custom_etc_volume_option=''
        fi

        run_cmd="docker run \
            -d \
            --rm \
            $pwd_volume_option \
            $etc_volume_option \
            --volume=$HOME_VOLUME:$HOME:ro \
            $custom_etc_volume_option \
            $log_volume_option \
            --name $CONTAINER_NAME \
            --hostname $CONTAINER_NAME.loc \
            --workdir $LIBRARY_DIR \
            --env PHPMV_RUNNING_USER=$USER \
            --env PHPMV_WORKDIR=$LIBRARY_DIR \
            jclaveau/php-multiversion:$docker_image_version /sbin/my_init \
        "
            # --network="bridge" \
        # Forcing /sbin/my_init without redirection to /dev/null ensures
        # the services and scripts are well run before a later container-exec
         # echo $run_cmd
         # exit

        eval "$run_cmd" > /dev/null # comment for debug
    fi
}

# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by() {
    local d=$1;
    shift;
    echo -n "$1";
    shift;
    printf "%s" "${@/#/$d}";
}

function exec_in_docker() {
    # avoid https://stackoverflow.com/questions/43099116/error-the-input-device-is-not-a-tty
    local USE_TTY printenv_array_length environment_vars value inline_env input_command_parts command
    test -t 1 && USE_TTY="-t"

    # Pass all environment variables to the container to mimic the development on the host
    readarray -t printenv_array <<< "$(printenv)"
    printenv_array_length=${#printenv_array[@]}
    environment_vars=()
    for (( i=0; i<printenv_array_length+1; i++ ));
    do
        if [[ ${printenv_array[i]} != "" ]]; then
            readarray -t parts <<< "$(sed '0,/=/s//\n/' <<< "${printenv_array[$i]}")" # split by first =
            if [[ "${parts[1]}" != "PATH" ]]; then
                value=$(sed -e "s/'/'\\\\''/g; 1s/^/'/; \$s/\$/'/" <<< "${parts[1]}") # escaping
                environment_vars+=("${parts[0]}=$value") # escape quoted value
            fi
        fi
    done

    inline_env=$(printf " --env %s" "${environment_vars[@]}")

    input_command_parts=\"$( join_by '" "' "$@" )\"
    command="docker exec -i ${USE_TTY} --user $(id -u):$(id -g) $inline_env $CONTAINER_NAME $input_command_parts"

    # echo $command
    # echo ""
    # exit
    eval "$command"
}

function latest_php_version() {
    exec_in_docker update-alternatives --query php | grep Best | sed "s/^[^[:digit:]]*//"
}

function kill_containers() {
    local container_ids
    container_ids=$(docker ps --no-trunc --format '{{.ID}} {{.Names}}' | awk '$2 ~ /^phpmv_.+/ { print $1}')

    if [ -n "$container_ids" ]; then
        # echo $container_ids
        # shellcheck disable=SC2086
        docker kill $container_ids
    fi
}

function kill_container() {
    local container_ids
    container_ids=$(docker ps --no-trunc --format '{{.ID}} {{.Names}}' | awk "\$2 ~ /^$CONTAINER_NAME/ { print \$1}")

    if [ -n "$container_ids" ]; then
        # echo $container_ids
        # shellcheck disable=SC2086
        docker kill $container_ids
    fi
}

function config_container() {
    local new_path

    # copy the missing files from ./etc_default to ./etc
    while IFS= read -r -d '' file
    do
        new_path=$(sed "s|etc_default|etc|g" <<< "$file")
        mkdir -p "$(dirname "$new_path")"
        if [ ! -f "$LIBRARY_DIR/$new_path" ]; then
            echo "$new_path"
            cp -n -r -p "$LIBRARY_DIR/$file" "$LIBRARY_DIR/$new_path"
        fi
    done <   <(find "./etc_default" -type "f" -print0)
}

function ps_container() {
    docker ps --filter name="$CONTAINER_NAME" --filter volume="$LIBRARY_DIR" "$@"
}

function ps_containers() {
    docker ps --filter "name=phpmv_" "$@"
}

function container_id() {
    ps_container --format '{{.ID}}'
}

function container_ip() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$(container_id)"
}

function container_logs() {
    docker logs "$(container_id)" "$@"
}
