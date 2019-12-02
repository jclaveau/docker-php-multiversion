Describe "php"
    Include ./functions.bash
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
    It "runs php in 5.6"
        When run source ./php 5.6 spec/phpversion.php
        The line 1 of stdout should eq "5.6"
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
