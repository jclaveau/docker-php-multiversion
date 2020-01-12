Describe "php"
    Include ./lib/functions.bash

    It "runs docker"
        When call run_docker $(pwd)

        The stdout should eq ""
        The stderr should eq ""
    End
    It "runs php in multiple versions"
        When run source ./php 5.6 7.0 7.3 spec/phpversion.php
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

        When run source ./php spec/phpversion.php
        The line 1 of stdout should eq $latest_version
        The stderr should eq ""
    End
    It "runs php in default version (latest)"
        LIBRARY_DIR=$(pwd)
        CONTAINER_NAME=php-mv'_'$(echo "$LIBRARY_DIR" | sed "s|[^[:alpha:].-]|_|g")
        run_docker $(pwd)
        latest_version=$(latest_php_version)

        When run source ./php $latest_version spec/phpversion.php
        The line 1 of stdout should eq $latest_version
        The stderr should eq ""
    End
    It "runs php in unsupported 5.5 without blocking"
        When run source ./php 5.5 5.6 spec/phpversion.php
        The line 1 of stdout should eq "Unsupported PHP version: 5.5"
        The line 2 of stdout should eq "5.6"
    End
    It "runs php in 5.6 from symlink"
        script_dir=$(dirname "$(readlink -f ".php")")
        ln -s $script_dir/php /tmp/php_for_testing
        When run source /tmp/php_for_testing 5.6 spec/phpversion.php
        rm /tmp/php_for_testing
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs multiple php containers and rerun the first one without conflict"
        # https://github.com/jclaveau/docker-php-multiversion/issues/16
        working_dir=$(pwd)
        $working_dir/php 5.6 $working_dir/spec/phpversion.php
        cd ..
        $working_dir/php 5.6 $working_dir/spec/phpversion.php
        cd $working_dir
        When run source $working_dir/php 5.6 spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs multiple php containers and kill them"
        # clean the containers first
        working_dir=$(pwd)
        $working_dir/php kill-containers
        $working_dir/php 5.6 $working_dir/spec/phpversion.php
        cd ..
        $working_dir/php 5.6 $working_dir/spec/phpversion.php
        cd $working_dir
        When run source $working_dir/php kill-containers
        The line 1 of stdout should not be blank # TODO pattern hexa
        The line 2 of stdout should not be blank
        # The line 3 of stdout should be blank
        The stderr should eq ""
    End
    It "runs multiple php containers and kill the one of pwd"
        # clean the containers first
        working_dir=$(pwd)
        $working_dir/php kill-containers
        $working_dir/php 5.6 $working_dir/spec/phpversion.php
        cd ..
        $working_dir/php 5.6 $working_dir/spec/phpversion.php
        cd $working_dir
        When run source $working_dir/php kill-container
        The line 1 of stdout should not be blank # TODO pattern hexa
        The line 2 of stdout should be blank
        The stderr should eq ""
        $working_dir/php kill-containers
    End
    It "lists container"
        BeforeRun './php -v > /dev/null'
        When run ./php container --format {{.Names}}
        The line 1 of stdout should match "php-mv_*_docker-php-multiversion"
        The line 2 of stdout should be blank
        The stderr should eq ""
    End
    It "lists containers"
        BeforeRun "./php kill-containers > /dev/null"
        BeforeRun './php -v > /dev/null'
        BeforeRun 'mkdir -p tmp'
        BeforeRun 'cd tmp'
        BeforeRun '../php -v > /dev/null'
        BeforeRun 'cd ..'
        When run ./php containers --format {{.Names}}
        The line 1 of stdout should match "php-mv_*_docker-php-multiversion_tmp"
        The line 2 of stdout should match "php-mv_*_docker-php-multiversion"
        The line 3 of stdout should be blank
        The stderr should eq ""
    End
    It "runs php with environment variables"
        BeforeRun "export COMPOSER_VENDOR_DIR='custom_vendor'"
        # export is required until inline environment variables are supported by Shellspec
        # When run source "COMPOSER_VENDOR_DIR='custom_vendor' ./php spec/getenv_composer_vendor_dir.php"
        When run source ./php spec/getenv_composer_vendor_dir.php
        The stdout should eq "COMPOSER_VENDOR_DIR=custom_vendor"
        The stderr should eq ""
    End
    It "runs php changing the image version"
        BeforeRun "./php kill-containers > /dev/null"
        BeforeRun "export PHP_MULTIVERSION_IMAGE='latest'"
        BeforeRun "./php spec/phpversion.php > /dev/null"
        When run source ./php container --format {{.Image}}
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
        When run source ./php -v
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
        When run source ./php -v
        The line 1 of stdout should eq "docker not installed"
        The line 2 of stdout should eq "sudo apt-get install docker.io"
        The line 3 of stdout should eq "Unable to launch docker installation. Please do it manually."
        The stderr should eq ""
        rm -rf spec/tmp_bin
    End
    It "configures ./etc directory"
        BeforeRun 'rm -rf ./etc'
        When run source ./php config-container
        The stdout should match "*./etc/README.txt*"
        The stdout should match "*./etc/php/apache2/custom-allversions-apache2-php.ini*"
        The stdout should match "*./etc/php/fpm/custom-allversions-fpm-php.ini*"
        The stdout should match "*./etc/php/cli/custom-allversions-cli-php.ini*"
        The stderr should eq ""
    End
    It "adds file to container:/etc/php"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './php config-container'
        BeforeRun './php kill-containers'
        BeforeRun 'sleep 1'
        When run source ./php container-exec ls /etc/php
        The stdout should match "*apache2*"
        The stdout should match "*cli*"
        The stdout should match "*fpm*"
        The stderr should eq ""
    End
    It "does not mount ./etc on /custom_etc if it's missing"
        BeforeRun 'rm -rf ./etc'
        BeforeRun './php kill-containers > /dev/null'
        When run source ./php container-exec ls /custom_etc
        The status should eq 2
        The stdout should eq ""
        The stderr should eq "ls: cannot access '/custom_etc': No such file or directory"
    End
    It "runs php in 5.6 from $HOME"
        # avoid duplicate mounted volume between $HOME and $libdir
        libdir=$(pwd)
        cd $HOME
        When run source "$libdir"/php 5.6 "$libdir"/spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
        # cd libdir
    End
    It "runs php in 5.6 by using container-exec"
        When run source ./php container-exec php 5.6 spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs php in 5.6"
        When run source ./php 5.6 spec/phpversion.php
        The stdout should eq "5.6"
        The stderr should eq ""
    End
    It "runs php in 7.0"
        When run source ./php 7.0 spec/phpversion.php
        The line 1 of stdout should eq "7.0"
        The stderr should eq ""
    End
    It "runs php in 7.1"
        When run source ./php 7.1 spec/phpversion.php
        The line 1 of stdout should eq "7.1"
        The stderr should eq ""
    End
    It "runs php in 7.2"
        When run source ./php 7.2 spec/phpversion.php
        The line 1 of stdout should eq "7.2"
        The stderr should eq ""
    End
    It "runs php in 7.3"
        When run source ./php 7.3 spec/phpversion.php
        The line 1 of stdout should eq "7.3"
        The stderr should eq ""
    End
    It "runs php in 7.4"
        When run source ./php 7.4 spec/phpversion.php
        The line 1 of stdout should eq "7.4"
        The stderr should eq ""
    End
End
