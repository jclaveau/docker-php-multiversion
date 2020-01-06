#!/bin/bash

apt-get update
apt-get upgrade

# apt-get install --no-install-recommends --no-install-suggests -y \

apt-get install -y \
    ca-certificates\
    software-properties-common\
    curl \
    git \
    gnupg \
    unzip \
    nano \
    htop \
    nmap \
    sudo \
    net-tools \
    zip \
    docker.io

add-apt-repository -y ppa:ondrej/php
apt-get update
