#!/bin/bash
# TODO start apache2 if /etc/apache2 exists
# TODO start nginx if /etc/nginx exists
# TODO start php builtin webserver if /etc/php/webserver exists

a2enmod alias proxy proxy_fcgi rewrite proxy_http
service apache2 start
service nginx start
service php5.6-fpm start
service php7.0-fpm start
service php7.1-fpm start
service php7.2-fpm start
service php7.3-fpm start
service php7.4-fpm start
