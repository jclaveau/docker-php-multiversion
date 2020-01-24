Describe "php"
    Include ./lib/functions.bash

    It "runs docker"
        When call run_docker $(pwd)

        The stdout should eq ""
        The stderr should eq ""
    End
    It "runs php in multiple versions"
        When run source ./bin/php 5.6 7.0 7.3 spec/phpversion.php
        The line 1 of stdout should eq "5.6"
        The line 2 of stdout should eq "7.0"
        The line 3 of stdout should eq "7.3"
        The stderr should eq ""
    End
    It "runs php in default version (default)"
        LIBRARY_DIR=$(pwd)
        CONTAINER_NAME=php-mv'_'$(echo "$LIBRARY_DIR" | sed "s|[^[:alpha:].-]|_|g")
        run_docker
        latest_version=$(latest_php_version)

        When run source ./bin/php spec/phpversion.php
        The line 1 of stdout should eq $latest_version
        The stderr should eq ""
    End
    It "runs php in default version (latest)"
        LIBRARY_DIR=$(pwd)
        CONTAINER_NAME=php-mv'_'$(echo "$LIBRARY_DIR" | sed "s|[^[:alpha:].-]|_|g")
        run_docker $(pwd)
        latest_version=$(latest_php_version)

        When run source ./bin/php $latest_version spec/phpversion.php
        The line 1 of stdout should eq $latest_version
        The stderr should eq ""
    End
    It "runs php in unsupported 5.5 without blocking"
        When run source ./bin/php 5.5 5.6 spec/phpversion.php
        The line 1 of stdout should eq "Unsupported PHP version: 5.5"
        The line 2 of stdout should eq "5.6"
    End
    It "runs php in 5.6 from symlink"
        script_dir=$(dirname "$(readlink -f ".php")")
        if [ -d "$script_dir"/bin ]; then
            script_dir="$script_dir"/bin
        fi
        ln -s $script_dir/php /tmp/php_for_testing
        When run source /tmp/php_for_testing 5.6 spec/phpversion.php
        rm /tmp/php_for_testing
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs multiple php containers and rerun the first one without conflict"
        # https://github.com/jclaveau/docker-php-multiversion/issues/16
        working_dir=$(pwd)
        $working_dir/bin/php 5.6 $working_dir/spec/phpversion.php
        cd ..
        $working_dir/bin/php 5.6 $working_dir/spec/phpversion.php
        cd $working_dir
        When run source $working_dir/bin/php 5.6 spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs multiple php containers and kill them"
        # clean the containers first
        working_dir=$(pwd)
        $working_dir/bin/php kill-containers
        $working_dir/bin/php 5.6 $working_dir/spec/phpversion.php
        cd ..
        $working_dir/bin/php 5.6 $working_dir/spec/phpversion.php
        cd $working_dir
        When run source $working_dir/bin/php kill-containers
        The line 1 of stdout should not be blank # TODO pattern hexa
        The line 2 of stdout should not be blank
        # The line 3 of stdout should be blank
        The stderr should eq ""
    End
    It "runs multiple php containers and kill the one of pwd"
        # clean the containers first
        working_dir=$(pwd)
        $working_dir/bin/php kill-containers
        $working_dir/bin/php 5.6 $working_dir/spec/phpversion.php
        cd ..
        $working_dir/bin/php 5.6 $working_dir/spec/phpversion.php
        cd $working_dir
        When run source $working_dir/bin/php kill-container
        The line 1 of stdout should not be blank # TODO pattern hexa
        The line 2 of stdout should be blank
        The stderr should eq ""
        $working_dir/bin/php kill-containers
    End
    It "lists container"
        BeforeRun './bin/php -v > /dev/null'
        When run ./bin/php container --format {{.Names}}
        The line 1 of stdout should match "php-mv_*_docker-php-multiversion"
        The line 2 of stdout should be blank
        The stderr should eq ""
    End
    It "lists containers"
        BeforeRun "./bin/php kill-containers > /dev/null"
        BeforeRun './bin/php -v > /dev/null'
        BeforeRun 'mkdir -p tmp'
        BeforeRun 'cd tmp'
        BeforeRun '../bin/php -v > /dev/null'
        BeforeRun 'cd ..'
        When run ./bin/php containers --format {{.Names}}
        The line 1 of stdout should match "php-mv_*_docker-php-multiversion_tmp"
        The line 2 of stdout should match "php-mv_*_docker-php-multiversion"
        The line 3 of stdout should be blank
        The stderr should eq ""
    End
    It "reruns a container"
        ./bin/php kill-containers > /dev/null
        ./bin/php -v > /dev/null
        container_id_before="$(./bin/php container --no-trunc --format {{.ID}})" # cannot use BeforeRun here
        When run ./bin/php rerun-container
        The line 1 of stdout should eq "$container_id_before"
        container_id_after="$(./bin/php container --no-trunc --format {{.ID}})"
        The line 2 of stdout should eq "$container_id_after"
        The line 3 of stdout should be blank
        The stderr should eq ""
    End
    
    It "runs container-ip"
        ./bin/php kill-container > /dev/null
        When run ./bin/php container-ip
        The stdout should match "*.*.*.*"
        The stderr should eq ""
    End
    
    It "runs container-logs"
        ./bin/php kill-container > /dev/null
        When run ./bin/php container-logs
        The line 1 of stdout should match '*syslog-ng*'
        The line 1 of stdout should match '*starting*'
        The line 1 of stderr should eq "*** Running /etc/my_init.d/00_regen_ssh_host_keys.sh..."
        The line 2 of stderr should eq "*** Running /etc/my_init.d/10_syslog-ng.init..."
    End
    
    It "runs php with environment variables"
        BeforeRun "export COMPOSER_VENDOR_DIR='custom_vendor'"
        # export is required until inline environment variables are supported by Shellspec
        # When run source "COMPOSER_VENDOR_DIR='custom_vendor' ./bin/php spec/getenv_composer_vendor_dir.php"
        When run source ./bin/php spec/getenv_composer_vendor_dir.php
        The stdout should eq "COMPOSER_VENDOR_DIR=custom_vendor"
        The stderr should eq ""
    End
    It "runs php changing the image version"
        BeforeRun "./bin/php kill-containers > /dev/null"
        BeforeRun "export PHP_MULTIVERSION_IMAGE='latest'"
        BeforeRun "./bin/php spec/phpversion.php > /dev/null"
        When run source ./bin/php container --format {{.Image}}
        The line 1 of stdout should match "*latest"
        The line 2 of stdout should be blank
        The stderr should eq ""
    End
    It "checks that docker.io is installed and don't"
        # change the $PATH to a directory not containing 'docker'
        mkdir -p spec/tmp_bin
        ln -s -f "$(command -v dirname)" spec/tmp_bin/dirname
        ln -s -f "$(command -v readlink)" spec/tmp_bin/readlink
        ln -s -f "$(command -v grep)" spec/tmp_bin/grep
        BeforeRun "export PATH='spec/tmp_bin'"
        Data
          #|
        End
        When run source ./bin/php -v
        The line 1 of stdout should eq "docker not installed"
        The line 2 of stdout should eq "Docker.io is required"
        The stderr should eq ""
        rm -rf spec/tmp_bin
    End
    It "checks that docker.io is installed and do it"
        # change the $PATH to a directory not containing 'docker'
        mkdir -p spec/tmp_bin
        ln -s -f "$(command -v dirname)" spec/tmp_bin/dirname
        ln -s -f "$(command -v readlink)" spec/tmp_bin/readlink
        ln -s -f "$(command -v grep)" spec/tmp_bin/grep
        # do not add sudo to let the installation fail during tests
        BeforeRun "export PATH='spec/tmp_bin'"
        Data
          #|y
        End
        When run source ./bin/php -v
        The line 1 of stdout should eq "docker not installed"
        The line 2 of stdout should eq "sudo apt-get install docker.io"
        The line 3 of stdout should eq "Unable to launch docker installation. Please do it manually."
        The stderr should eq ""
        rm -rf spec/tmp_bin
    End
    
    It "configures ./etc directory"
        BeforeRun 'rm -rf ./etc'
        When run source ./bin/php config-container
        The stdout should match "*./etc/README.txt*"
        The stdout should match "*./etc/php/apache2/custom-allversions-apache2-php.ini*"
        The stdout should match "*./etc/php/fpm/custom-allversions-fpm-php.ini*"
        The stdout should match "*./etc/php/cli/custom-allversions-cli-php.ini*"
        The stderr should eq ""
    End
    
    It "adds file to container:/etc/php"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './bin/php config-container'
        BeforeRun './bin/php kill-containers'
        BeforeRun 'sleep 1'
        When run source ./bin/php container-exec ls /etc/php
        The stdout should match "*apache2*"
        The stdout should match "*cli*"
        The stdout should match "*fpm*"
        The stderr should eq ""
    End
    
    It "does not mount ./etc on /custom_etc if it's missing"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './bin/php kill-containers > /dev/null'
        When run source ./bin/php container-exec ls /custom_etc
        The status should eq 2
        The stdout should eq ""
        The stderr should eq "ls: cannot access '/custom_etc': No such file or directory"
    End

    It "does not mount ./log on /host_log if it's missing"
        BeforeRun 'rm -rf ./log 2>&1 >/dev/null'
        BeforeRun './bin/php kill-containers > /dev/null'
        When run source ./bin/php container-exec ls /host_log
        The status should eq 2
        The stdout should eq ""
        The stderr should eq "ls: cannot access '/host_log': No such file or directory"
    End
    
    It "writes logs to container:/log"
        check_syslog_owned_by_user() {
            ./bin/php kill-containers > /dev/null
            rm -rf ./log/*
            mkdir -p ./log
            ./bin/php -v > /dev/null
            sleep 1
            ls ./log/syslog
            stat -c '%U' ./log/syslog
        }
        When call check_syslog_owned_by_user
        The line 1 of stdout should match "./log/syslog"
        The line 2 of stdout should match "$USER"
        The line 3 of stdout should be blank
        The stderr should eq ""
    End

    It " starts httpd services"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './bin/php rerun-container'
        BeforeRun 'sleep 2'
        list_httpd_services() {
            ./bin/php container-exec service --status-all | grep -E 'apache2|nginx|php'
        }
        When call list_httpd_services
        The line 1 of stdout should eq " [ + ]  apache2"
        The line 2 of stdout should eq " [ + ]  nginx"
        The line 3 of stdout should eq " [ + ]  php5.6-fpm"
        The line 4 of stdout should eq " [ + ]  php7.0-fpm"
        The line 5 of stdout should eq " [ + ]  php7.1-fpm"
        The line 6 of stdout should eq " [ + ]  php7.2-fpm"
        The line 7 of stdout should eq " [ + ]  php7.3-fpm"
        The line 8 of stdout should eq " [ + ]  php7.4-fpm"
        The line 1 of stderr should eq " [ ? ]  hwclock.sh"
        The line 2 of stderr should eq " [ ? ]  ubuntu-fan"
    End
    
    It " starts php builtin webserver services"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './bin/php rerun-container'
        BeforeRun 'sleep 2'
        list_webserver_services() {
            ./bin/php container-exec ps --sort cmd -u "$USER" | grep -E 'php'
        }
        When call list_webserver_services
        The word 4 of line 1 of stdout should eq "php5.6"
        The word 4 of line 2 of stdout should eq "php7.0"
        The word 4 of line 3 of stdout should eq "php7.1"
        The word 4 of line 4 of stdout should eq "php7.2"
        The word 4 of line 5 of stdout should eq "php7.3"
        The word 4 of line 6 of stdout should eq "php7.4"
        The line 7 of stdout should be blank
        The stderr should be blank
    End
    
    It "serves php of the right version with apache2, nginx, php builtin webserver"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './bin/php rerun-container > /dev/null'
        BeforeRun 'sleep 2'
        serves_vhosts_with_the_expected_php_version() {
            ip_address="$(./bin/php container-ip)"
            curl --silent http://"$ip_address":8000/spec/phpversion.php
            curl --silent http://"$ip_address":8010/spec/phpversion.php
            curl --silent http://"$ip_address":8056/spec/phpversion.php
            curl --silent http://"$ip_address":8070/spec/phpversion.php
            curl --silent http://"$ip_address":8071/spec/phpversion.php
            curl --silent http://"$ip_address":8072/spec/phpversion.php
            curl --silent http://"$ip_address":8073/spec/phpversion.php
            curl --silent http://"$ip_address":8074/spec/phpversion.php
        }
        When call serves_vhosts_with_the_expected_php_version
        The line 1 of stdout should eq "7.4"
        The line 2 of stdout should eq "7.4"
        The line 3 of stdout should eq "5.6"
        The line 4 of stdout should eq "7.0"
        The line 5 of stdout should eq "7.1"
        The line 6 of stdout should eq "7.2"
        The line 7 of stdout should eq "7.3"
        The line 8 of stdout should eq "7.4"
        The line 9 of stdout should be blank
        The stderr should be blank
    End
    
    It "runs php in 5.6 from $HOME"
        # avoid duplicate mounted volume between $HOME and $libdir
        libdir=$(pwd)
        cd $HOME
        When run source "$libdir"/bin/php 5.6 "$libdir"/spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs php in 5.6 by using container-exec"
        When run source ./bin/php container-exec php 5.6 spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs php in 5.6"
        When run source ./bin/php 5.6 spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs php in 7.0"
        When run source ./bin/php 7.0 spec/phpversion.php
        The line 1 of stdout should eq "7.0"
        The stderr should eq ""
    End
    It "runs php in 7.1"
        When run source ./bin/php 7.1 spec/phpversion.php
        The line 1 of stdout should eq "7.1"
        The stderr should eq ""
    End
    It "runs php in 7.2"
        When run source ./bin/php 7.2 spec/phpversion.php
        The line 1 of stdout should eq "7.2"
        The stderr should eq ""
    End
    It "runs php in 7.3"
        When run source ./bin/php 7.3 spec/phpversion.php
        The line 1 of stdout should eq "7.3"
        The stderr should eq ""
    End
    It "runs php in 7.4"
        When run source ./bin/php 7.4 spec/phpversion.php
        The line 1 of stdout should eq "7.4"
        The stderr should eq ""
    End

    
    It "completes command line: php only"
        complete_suggestions() {
                export PATH="$(pwd)/bin:$PATH"
                source $(pwd)/share/bash-completion/completions/php.bash
                export COMP_LINE="php"
                export COMP_WORDS=(php)
                export COMP_CWORD=1
                export COMP_POINT=3
                
                complete_command=$(complete -p | sed "s/.*-F \\([^ ]*\\) .*/\\1/")
                eval "$complete_command"
                echo "${COMPREPLY[@]}"
        }
        When call complete_suggestions
        The stdout should eq "containers container kill-containers kill-container rerun-container config-container container-exec container-ip container-logs 5.6 7.0 7.1 7.2 7.3 7.4"
        The stderr should eq ""
    End

    It "completes command line: php co"
        complete_suggestions() {
                export PATH="$(pwd)/bin:$PATH"
                source $(pwd)/share/bash-completion/completions/php.bash
                export COMP_LINE="php co"
                export COMP_WORDS=(php co)
                export COMP_CWORD=2
                export COMP_POINT=5
                
                complete_command=$(complete -p | sed "s/.*-F \\([^ ]*\\) .*/\\1/")
                eval "$complete_command"
                echo "${COMPREPLY[@]}"
        }
        When call complete_suggestions
        The stdout should eq "containers container config-container container-exec container-ip container-logs"
        The stderr should eq ""
    End

    It "completes command line: php kil"
        complete_suggestions() {
                export PATH="$(pwd)/bin:$PATH"
                source $(pwd)/share/bash-completion/completions/php.bash
                export COMP_LINE="php kil"
                export COMP_WORDS=(php kil)
                export COMP_CWORD=2
                export COMP_POINT=6
                
                complete_command=$(complete -p | sed "s/.*-F \\([^ ]*\\) .*/\\1/")
                eval "$complete_command"
                echo "${COMPREPLY[@]}"
        }
        When call complete_suggestions
        The stdout should eq "kill-containers kill-container"
        The stderr should eq ""
    End
End
