#!/bin/bash

apt-get update &&\
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates\
        software-properties-common\
        curl \
        git \
        gnupg \
        unzip \
        nano \
        htop \
        nmap \
        net-tools \
        zip &&\

add-apt-repository ppa:ondrej/php
apt-get update

versions=(5.6 7.0 7.1 7.2 7.3 7.4)
# versions=(7.4)
for php_version in "${versions[@]}"
do
    apt-get install -y \
        php$php_version-fpm \
        php$php_version \
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
        php$php_version-uuid \
        php$php_version-opcache\
        php$php_version-zmq
done

# sebastian/global-state suggests installing ext-uopz (*) # https://github.com/oerdnj/deb.sury.org/issues/1269


versions=(5.6 7.0 7.1)
for php_version in "${versions[@]}"
do
    apt-get install -y \
        php$php_version-mcrypt
        
done

apt-get install --no-install-recommends --no-install-suggests -y \
    php-xdebug\
    docker.io

apt-get -y --purge autoremove &&\
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/{man,doc}

apt-get update
