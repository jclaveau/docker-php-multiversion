# Docker PHP Multiversion
Use PHP in the version you prefer with nothing more than Docker installed (for development purpose).

[![Build Status](https://travis-ci.org/jclaveau/docker-php-multiversion.png?branch=master)](https://travis-ci.org/jclaveau/docker-php-multiversion)
[![codecov](https://codecov.io/gh/jclaveau/docker-php-multiversion/branch/master/graph/badge.svg)](https://codecov.io/gh/jclaveau/docker-php-multiversion)

## Install
```
curl -fsSL https://raw.githubusercontent.com/jclaveau/docker-php-multiversion/master/installer.sh | sh
```
Or with [bpkg/bpkg](https://github.com/bpkg/bpkg#bpkg---)
```
sudo bpkg install -g jclaveau/docker-php-multiversion
```

## Usage
```shell
$ php 7.1 spec/phpversion.php
$ 7.1
$ php 7.1 5.6 spec/phpversion.php
$ 7.1
$ 5.6
```
If you installed PHP locally it's still available but only in the version you installed
```shell
$ /usr/bin/php spec/phpversion.php
```


This works also with `phpunit`
```shell
$ php 7.1 vendor/bin/phpunit
```
and `composer`
```shell
$ php 7.1 /usr/bin/composer
```

## Managing containers
You can list php-multiversion containers ([Supporting all options of docker ps](https://docs.docker.com/engine/reference/commandline/ps/))
```shell
$ php containers # all running containers
$ php container  # container attached to the current directory
```
You can kill/rerun containers
```shell
$ php kill-containers # all running containers
$ php kill-container  # container attached to the current directory
$ php rerun-container # kill then run current container 
```
You can also exec whatever you want in the container attached to your current working dir
```shell
$ php container-exec bash
```

## Logging
 + If you create à `host:./log` folder, all the content of `container:/var/log` will be placed inside in realtime.
 + A call to `php rerun-container` is required if the `host:./log` folder is created after the container is run.
 + The user who run the container always owns all the content of  `host:./log`.

## Container configuration
 + All the content of `<container>:/etc` would be overriden by the content of `<host>:<your project path>/etc`.
 + Calling `php config-container` will prepare a `<container>:/etc` having the content `<container>:/etc_default`
 + It contains empty files in `./etc/php` which are read after the loading of all PHP configurations, enabling you to change any option instantly.
 + You can read the current config with `php 7.4 -i`
 + You can access directly the current configuration value wth `php container-exec nano /etc/php/7.4/cli/php.ini` but it wouldn't persist after a container restart.

## PHP Versions
This docker image provides all PHP versions available in [Ondřej Surý's PPA](https://github.com/oerdnj/deb.sury.org).

## Production
For production purpose I recommend [jtreminio/php-docker](https://github.com/jtreminio/php-docker) image which provides a light image of PHP in any version of the same PPA.

## FPM
My use case is presently centered around php-cli and I have a lot of work before matching my expectations but using it as a multiversion cli provider could be interesting also later.
