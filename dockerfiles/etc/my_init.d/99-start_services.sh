#!/bin/bash
# TODO start apache2 if /etc/apache2 exists
# TODO start nginx if /etc/nginx exists
# TODO start php builtin webserver if /etc/php/webserver exists

echo "export PHPMV_WORKDIR='$PHPMV_WORKDIR'" >> /etc/apache2/envvars
echo "export PHPMV_RUNNING_USER='$PHPMV_RUNNING_USER'" >> /etc/apache2/envvars

a2enmod alias proxy proxy_fcgi rewrite proxy_http
service apache2 start
service nginx start
service php5.6-fpm start
service php7.0-fpm start
service php7.1-fpm start
service php7.2-fpm start
service php7.3-fpm start
service php7.4-fpm start
