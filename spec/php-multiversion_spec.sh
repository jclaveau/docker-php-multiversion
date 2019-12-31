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
        run_docker $(pwd)
        latest_version=$(latest_php_version)

        When run source ./php spec/phpversion.php
        The line 1 of stdout should eq $latest_version
        The stderr should eq ""
    End
    It "runs php in default version (latest)"
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
    It "runs php with environment variables"
        COMPOSER_VENDOR_DIR='custom_vendor'
        export COMPOSER_VENDOR_DIR
        # export is required until inline environment variables are supported by Shellspec
        # When run source "COMPOSER_VENDOR_DIR='custom_vendor' ./php spec/getenv_composer_vendor_dir.php"
        When run source ./php spec/getenv_composer_vendor_dir.php
        The stdout should eq "COMPOSER_VENDOR_DIR=custom_vendor"
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
