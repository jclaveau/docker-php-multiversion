#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")

# shellcheck source=lib/functions.bash
source "$script_dir/lib/functions.bash"

if ! in_docker_container; then
    install_docker_if_missing
# else
    # echo "in_docker_container"
fi

LIBRARY_DIR="$(pwd)"
# shellcheck disable=SC2001
CONTAINER_NAME=php-mv'_'$(echo "$LIBRARY_DIR" | sed "s|[^[:alpha:].-]|_|g")

versions=()

while :; do
    if [ "$1" == 'commands' ]; then
        shift
        # echo "commands => $@"
        propositions=()
        
        if [ "$2" != "containers" ]
        then
            propositions+=("containers")
            propositions+=("container")
        fi

        if [ "$2" != "kill-containers" ]
        then
            propositions+=("kill-containers")
            propositions+=("kill-container")
        fi

        ends=(rerun-container config-container container-exec)
        for i in "${ends[@]}"
        do
            if [ "$2" != "$i" ]
            then
                propositions+=("$i")
            fi
        done

        versions=(5.6 7.0 7.1 7.2 7.3 7.4)
        for version in "${versions[@]}"
        do
            skip=
            for j in "$@"; do
                if [[ "$version" == "$j" ]]; then
                    skip=1;
                    break;
                fi
            done
            
            [[ -n $skip ]] || propositions+=("$version")
        done

        # for file in $(ls)
        # do
            # propositions+=(./"$file")
        # done
        
        for i in "${propositions[@]}"; do
            echo "$i"
        done
        
        exit
    fi

    if [ "$1" == 'kill-containers' ]; then
        kill_containers
        exit
    fi

    if [ "$1" == 'kill-container' ]; then
        kill_container
        exit
    fi

    if [ "$1" == 'rerun-container' ]; then
        shift
        kill_container
        run_docker
        ps_container --no-trunc --format "{{.ID}}"
        exit
    fi

    if [ "$1" == 'container-exec' ]; then
        shift
        run_docker
        exec_in_docker "$@"
        exit
    fi

    if [ "$1" == 'config-container' ]; then
        config_container
        exit
    fi

    if [ "$1" == 'container' ]; then
        shift
        ps_container "$@"
        exit
    fi

    if [ "$1" == 'containers' ]; then
        shift
        ps_containers "$@"
        exit
    fi

    if awk -v version="$1" 'BEGIN{ exit (version ~ /^[0-9]+.[0-9]+$/) }' ; then
        # not a version
        break
    fi

    if awk -v version="$1" 'BEGIN{ exit (version == 5.6 || version >= 7) }' ; then
        echo "Unsupported PHP version: $1"
    else
        versions+=("$1")
    fi

    shift
done

if [ ${#versions[@]} == 0 ]; then
    versions+=("")
fi

if in_docker_container; then
    # we do not need to restart a container with php multiversion as we already are in
    for version in "${versions[@]}";
    do
        # In case php multiversion is run from ~/.local/bin calling "php -v"
        # will loop infinitelly so we force the next php to be found in /usr/bin
        /usr/bin/php"$version" "$@"
    done
else
    run_docker

    for version in "${versions[@]}";
    do
        exec_in_docker "php$version" "$@"
    done
fi
