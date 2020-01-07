FROM phusion/baseimage:master
LABEL maintainer="Jean Claveau <jean.claveau@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN update-alternatives --install /bin/sh sh /bin/bash 100

# Most common PHP modules, and Composer
# First group of modules are enabled by default
COPY dockerfiles/install-tools-upgrade-repos.sh .
RUN ./install-tools-upgrade-repos.sh

COPY dockerfiles/install-php-packages.sh .
RUN ./install-php-packages.sh

RUN apt-get update && apt-get install composer -y
RUN apt-get upgrade -y

RUN apt-get install make  &&\
    sudo curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | sudo bash &&\
    sudo bpkg install -g jclaveau/docker-php-multiversion

# syncing configuration
COPY dockerfiles/lsyncd.conf /etc/lsyncd.conf
COPY dockerfiles/lsyncd.sh /etc/my_init.d/lsyncd.sh
RUN apt-get install lsyncd -y \
    && mkdir -p /etc/my_init.d \
    && chmod +x /etc/my_init.d/lsyncd.sh

RUN apt-get -y --purge autoremove &&\
    apt-get clean &&\
    rm -rf /tmp/* /var/tmp/* /usr/share/{man,doc} &&\
    apt-get update \
    && updatedb

# Xdebug CLI debugging
# COPY files/xdebug /usr/bin/xdebug
# RUN chmod +x /usr/bin/xdebug

# EXPOSE 9000


CMD ["/sbin/my_init"]
