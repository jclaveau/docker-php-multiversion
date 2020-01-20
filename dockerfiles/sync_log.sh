#!/bin/bash

if [ -d "/host_log/" ]; then
    # copy everything from log to host_log
    cp -R -p -b -d -f -v /var/log/* /host_log
    # replace log folder by a symlink
    mv /var/log /var/log.bak
    ln -s -v /host_log /var/log

    # loop of chown
    while true
    do
        sudo chown -R $PHPMV_RUNNING_USER: /host_log/*
        sleep 1
    done
fi
