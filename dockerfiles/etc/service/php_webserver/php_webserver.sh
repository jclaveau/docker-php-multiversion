#!/bin/bash
# See: https://www.php.net/manual/en/features.commandline.webserver.php

# runit doesn't support services containing a '.' or digits seperated with '_'
service_name="$(basename "$(pwd)" )"
php_version=$(sed -e 's/php_webserver_//' <<< "$service_name")
php_version=$(sed -e 's/-/./' <<< "$php_version")

if awk -v version="$php_version" 'BEGIN{ exit (version == 5.6 || version >= 7) }' ; then
    echo "$service_name: Unsupported PHP version: '$php_version'"
    exit;
fi

php_port=$(sed -e 's/\.//' <<< "$php_version")

config_file="/etc/php/web-server/php-webserver-$php_version.ini"
router_file="$PHPMV_WORKDIR/php-webserver-router.php"

log_dir='/var/log/php-webserver'
log_access_file="$log_dir/webserver_$php_version.access.log"
log_error_file="$log_dir/webserver_$php_version.error.log"

# echo "$php_version"
# echo "$php_port"
# echo "$config_file"
# echo "$router_file"
# echo "$log_dir"
# echo "$log_access_file"
# echo "$log_error_file"

if [ -f "$config_file" ]; then
    conf_option=" -c '$config_file'"
else
    conf_option=''
fi

if [ -f "$router_file" ]; then
    router_option="$router_file"
else
    router_option=''
fi

mkdir -p "$log_dir"
touch "$log_access_file"
touch "$log_error_file"

(exec /sbin/setuser "$PHPMV_RUNNING_USER" \
    /usr/bin/php"$php_version" \
        -t "$PHPMV_WORKDIR" \
        $conf_option \
        -S 0.0.0.0:80"$php_port" \
        $router_option \
     | tee "$log_access_file") 3>&1 1>&2 2>&3 | tee "$log_error_file"