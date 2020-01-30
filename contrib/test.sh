#!/bin/bash

if [ ! -d '/tmp/shellspec' ]; then
    git clone https://github.com/shellspec/shellspec.git /tmp/shellspec
fi

# /tmp/shellspec/shellspec --focus
/tmp/shellspec/shellspec --example *nginx*
