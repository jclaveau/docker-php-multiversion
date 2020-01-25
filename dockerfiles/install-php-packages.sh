#!/bin/bash

versions=(5.6 7.0 7.1 7.2 7.3 7.4)
# versions=(5.6)
for php_version in "${versions[@]}"
do
    apt-get install -y \
        php$php_version \
        php$php_version-fpm \
        php$php_version-bcmath \
        php$php_version-cli \
        php$php_version-curl \
        php$php_version-fpm \
        php$php_version-intl \
        php$php_version-json \
        php$php_version-mbstring \
        php$php_version-mysql \
        php$php_version-xml \
        php$php_version-zip \
        php$php_version-amqp \
        php$php_version-apcu \
        php$php_version-gd \
        php$php_version-geoip \
        php$php_version-gnupg \
        php$php_version-igbinary \
        php$php_version-imagick \
        php$php_version-lua \
        php$php_version-mailparse \
        php$php_version-memcached \
        php$php_version-mongodb \
        php$php_version-oauth \
        php$php_version-radius \
        php$php_version-raphf \
        php$php_version-redis \
        php$php_version-soap \
        php$php_version-solr \
        php$php_version-sqlite3 \
        php$php_version-ssh2 \
        php$php_version-stomp \
        php$php_version-uploadprogress \
        php$php_version-opcache\
        php$php_version-zmq
done

versions=(5.6 7.0 7.1)
for php_version in "${versions[@]}"
do
    apt-get install -y \
        php$php_version-mcrypt
done

apt-get install -y \
    php-xdebug\
    php-uopz\
    php-uuid

# disable uopz by default to avoid breaking exit / die()
phpdismod uopz
