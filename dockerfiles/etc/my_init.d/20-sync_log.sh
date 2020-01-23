#!/bin/bash
# See: /etc/service/chown_log.sh

if [ -d "/host_log/" ]; then
    # copy everything from log to host_log
    cp -R -p -b -d -f -v /var/log/* /host_log
    # replace log folder by a symlink
    mv /var/log /var/log.bak
    ln -s -v /host_log /var/log
    chown -R $PHPMV_RUNNING_USER: /host_log/*
fi
