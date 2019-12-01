# WIP: docker-php-multiversion
Use PHP in the version you prefer or multiple ones with nothing more than Docker installed for development purpose.

## Install
```
curl -fsSL https://raw.githubusercontent.com/jclaveau/docker-php-multiversion/master/installer.sh | sh

grep -qxF 'PATH=~/opt/bin:$PATH' ~/.profile || echo 'PATH=~/opt/bin:$PATH' >> ~/.profile
source ~/.profile
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
And with `composer` with a little more hacking i work on in my [PHP Library Development Toolkit](https://github.com/jclaveau/php-library-development-toolkit)


## PHP Versions
This docker image provides all PHP versions available in [Ondřej Surý's PPA](https://github.com/oerdnj/deb.sury.org).

## Production
For production purpose I recommend [jtreminio/php-docker](https://github.com/jtreminio/php-docker) image which provides a light image of PHP in any version of the same PPA.

## FPM
My use case is presently centered around php-cli and I have a lot of work before matching my expectations but using it as a multiversion fpm provider could be interesting also later.
