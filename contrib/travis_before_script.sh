#!/bin/bash

sudo apt-get update

if [ -z "$(command -v kcov)"]; then
    sudo apt-get install -y make
    sudo apt-get install -y bash binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev
    git clone https://github.com/SimonKagstrom/kcov.git
    cd kcov
    mkdir build; cd build; cmake ..; make -j4; sudo make install
    cd ../..
fi

if [ ! -d '/tmp/shellspec' ]; then
    git clone https://github.com/shellspec/shellspec.git /tmp/shellspec
fi
