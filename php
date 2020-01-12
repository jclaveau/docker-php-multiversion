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
    if [ "$1" == 'kill-containers' ]; then
        kill_containers
        exit
    fi

    if [ "$1" == 'kill-container' ]; then
        kill_container
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
