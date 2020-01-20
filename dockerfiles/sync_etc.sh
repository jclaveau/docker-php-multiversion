#!/bin/sh

# start lsync between /custom_etc and /etc
if [ -d "/custom_etc/" ]; then
    lsyncd -log all /etc/lsyncd.conf >>/var/log/lsyncd_start.log 2>&1
    # lsyncd  -log all /etc/lsyncd.conf
fi

# Add symlinkfs from php's con.d to conf on the host
php_versions=(5.6 7.0 7.1 7.2 7.3 7.4)
for php_version in "${php_versions[@]}"
do
    php_modes=(cli fpm apache2)
    for php_mode in "${php_modes[@]}"
    do
        if [ -d /etc/php/"$php_version"/"$php_mode"/conf.d/ ]
        then
            cd /etc/php/"$php_version"/"$php_mode"/conf.d/
            ln -s /etc/php/"$php_mode"/custom-allversions-cli-php.ini /etc/php/"$php_version"/"$php_mode"/conf.d/98-custom-allversions-"$php_mode"-php.ini
            ln -s /etc/php/"$php_mode"/custom-"$php_version"-cli-php.ini /etc/php/"$php_version"/"$php_mode"/conf.d/99-custom-"$php_version"-"$php_mode"-php.ini
        fi
    done
done
