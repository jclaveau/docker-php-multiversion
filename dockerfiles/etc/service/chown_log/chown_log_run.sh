#!/bin/bash
# All the log files are stored in /host_log which is a shared volume.
# As services are not run as $USER, we chown them every second to make
# them easily deletable bu the user.
# See: /etc/my_init.d/20-sync_log.sh

if [ -d "/host_log/" ]; then
    while true
    do
        chown -R $PHPMV_RUNNING_USER: /host_log/*
        sleep 1
    done
fi
