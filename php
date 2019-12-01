#!/bin/bash

source functions.bash

if ! in_docker_container; then 
    install_docker_if_missing
fi

versions=()

while :; do
    if awk -v version=$1 'BEGIN{ exit (version ~ /^[0-9]+.[0-9]+$/) }' ; then 
        # not a version
        break
    fi
    
    if awk -v version=$1 'BEGIN{ exit (version == 5.6 || version >= 7) }' ; then 
        echo "Unsupported PHP version: $1"
    else
        versions+=($1)
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
        php$version "$@"
    done
else 
    run_docker $(pwd)

    for version in "${versions[@]}"; 
    do 
        exec_in_docker php$version "$@"
    done
fi
