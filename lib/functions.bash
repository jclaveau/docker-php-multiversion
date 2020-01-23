#!/bin/bash

function in_docker_container() {
    # TODO check that the container is of jclaveau/php-multiversion
    if [[ -f /.dockerenv ]] || grep -Eq '(lxc|docker)' /proc/1/cgroup; then
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

function run_docker() {
    local lib_volume_option docker_image_version

    if ! docker ps -a | grep -q "$CONTAINER_NAME$"
    then
        # echo "Running new docker jclaveau/php-multiversion for $(pwd)"
        if [ "$HOME" != "$LIBRARY_DIR" ]; then
            lib_volume_option="--volume $LIBRARY_DIR:$LIBRARY_DIR"
        else
            lib_volume_option=''
        fi

        if [ -d "$LIBRARY_DIR/log" ]; then
            log_volume_option="--volume=$LIBRARY_DIR/log:/host_log"
        else
            log_volume_option=''
        fi

        if [ -d "$LIBRARY_DIR/etc" ]; then
            etc_volume_option="--volume=$LIBRARY_DIR/etc:/custom_etc"
        else
            etc_volume_option=''
        fi

        if [ -z "${PHP_MULTIVERSION_IMAGE:-}" ]; then
            docker_image_version='0.5.1'
            # docker_image_version='latest'
        else
            docker_image_version=$PHP_MULTIVERSION_IMAGE
        fi

        run_stdin=$( docker run \
            -d \
            --rm \
            --volume="$HOME":"$HOME":ro \
            --volume="$HOME"/.composer:"$HOME"/.composer:rw \
            $lib_volume_option \
            $etc_volume_option \
            $log_volume_option \
            --volume=/etc/group:/etc/group:ro \
            --volume=/etc/passwd:/etc/passwd:ro \
            --volume=/etc/shadow:/etc/shadow:ro \
            --volume=/etc/sudoers.d:/etc/sudoers.d:ro \
            --name "$CONTAINER_NAME" \
            --workdir "$LIBRARY_DIR" \
            --env PHPMV_RUNNING_USER="$USER" \
            jclaveau/php-multiversion:"$docker_image_version" /sbin/my_init \
        )
        # Forcing /sbin/my_init without redirection to /dev/null ensures
        # the services and scripts are well run before a later container-exec

        echo "$run_stdin" > /dev/null # comment for debug
    fi
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

    input_command_parts=("$@")
    command="docker exec -i ${USE_TTY} --user $(id -u):$(id -g) $inline_env $CONTAINER_NAME ${input_command_parts[*]}"

    # echo $command
    # echo ""
    eval "$command"
}

function latest_php_version() {
    exec_in_docker update-alternatives --query php | grep Best | sed "s/^[^[:digit:]]*//"
}

function kill_containers() {
    local container_ids
    container_ids=$(docker ps --no-trunc --format '{{.ID}} {{.Names}}' | awk '$2 ~ /^php-mv_.+/ { print $1}')

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
    docker ps --filter "name=php-mv_" "$@"
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
