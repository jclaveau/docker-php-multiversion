FROM phusion/baseimage:master
LABEL maintainer="Jean Claveau <jean.claveau@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN update-alternatives --install /bin/sh sh /bin/bash 100

# Most common PHP modules, and Composer
# First group of modules are enabled by default
COPY install-tools-upgrade-repos.sh .
RUN ./install-tools-upgrade-repos.sh

COPY install-php-packages.sh .
RUN ./install-php-packages.sh

RUN apt-get update
RUN apt-get install composer -y
RUN apt-get upgrade -y

RUN apt-get -y --purge autoremove &&\
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/{man,doc}
RUN apt-get update


# Xdebug CLI debugging
# COPY files/xdebug /usr/bin/xdebug
# RUN chmod +x /usr/bin/xdebug

# EXPOSE 9000

CMD ["/sbin/my_init"]
