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

        if [ -z "${PHP_MULTIVERSION_IMAGE:-}" ]; then
            docker_image_version='0.2.1'
        else
            docker_image_version=$PHP_MULTIVERSION_IMAGE
        fi

        docker run \
            -d \
            --rm \
            --volume="$HOME":"$HOME":ro \
            --volume="$HOME"/.composer:"$HOME"/.composer:rw \
            $lib_volume_option \
            --volume=/etc/group:/etc/group:ro \
            --volume=/etc/passwd:/etc/passwd:ro \
            --volume=/etc/shadow:/etc/shadow:ro \
            --volume=/etc/sudoers.d:/etc/sudoers.d:ro \
            --name "$CONTAINER_NAME" \
            --workdir "$LIBRARY_DIR" \
            jclaveau/php-multiversion:"$docker_image_version" > /dev/null
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
