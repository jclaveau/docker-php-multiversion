#!/bin/bash

# saved_path=$PATH
# export PATH=$(pwd)/bin:$PATH
# echo $PATH

# source ~/.profile
if [ ! -d '/tmp/shellspec' ]; then
    git clone https://github.com/shellspec/shellspec.git /tmp/shellspec
fi
# cd $(dirname $(command -v php))
# pwd
/tmp/shellspec/shellspec --fail-fast
# /tmp/shellspec/shellspec --focus

# export PATH=$saved_path


	# saved_path=$PATH
	# export PATH=$(pwd)/bin:$PATH
	# echo $PATH
	# export PATH=$(pwd)/bin:$$PATH; echo $$PATH;
	# . ~/.profile
	# command -v php
	# if [ ! -d 'shellspec' ]; then git clone https://github.com/shellspec/shellspec.git; fi
	# ./shellspec/shellspec --fail-fast
	# export PATH=$saved_path
