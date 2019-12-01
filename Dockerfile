FROM phusion/baseimage:latest
LABEL maintainer="Jean Claveau <jean.claveau@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN update-alternatives --install /bin/sh sh /bin/bash 100

# Most common PHP modules, and Composer
# First group of modules are enabled by default
COPY install-packages.sh .
RUN ./install-packages.sh

# Install the latest Composer (Phusion one is old)
RUN install -d -m 0755 -o www-data -g www-data /.composer &&\
    curl -sS https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin \
               --filename=composer &&\
    chown -R www-data:www-data /.composer

# Xdebug CLI debugging
# COPY files/xdebug /usr/bin/xdebug
# RUN chmod +x /usr/bin/xdebug

# EXPOSE 9000

CMD ["/sbin/my_init"]
