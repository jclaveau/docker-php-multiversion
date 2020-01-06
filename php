#!/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")

# shellcheck source=lib/functions.bash
source "$script_dir/lib/functions.bash"

if ! in_docker_container; then
    install_docker_if_missing
# else
    # echo "in_docker_container"
fi

versions=()

while :; do
    if [ "$1" == 'kill-containers' ]; then
        kill_containers
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
        PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' "php$version" "$@"
    done
else
    run_docker "$(pwd)"

    for version in "${versions[@]}";
    do
        exec_in_docker "php$version" "$@"
    done
fi
