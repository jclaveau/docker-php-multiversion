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

You can also kill all running php-multiversion containers
```shell
$ php kill-containers
```
Or the container of your current working dir
```shell
$ php kill-container
```
You can also exec whatever you want in container of your current working dir
```shell
$ php container-exec bash
```

## PHP Versions
This docker image provides all PHP versions available in [Ondřej Surý's PPA](https://github.com/oerdnj/deb.sury.org).

## Production
For production purpose I recommend [jtreminio/php-docker](https://github.com/jtreminio/php-docker) image which provides a light image of PHP in any version of the same PPA.

## FPM
My use case is presently centered around php-cli and I have a lot of work before matching my expectations but using it as a multiversion fpm provider could be interesting also later.
