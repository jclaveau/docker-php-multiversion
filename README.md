# WIP: docker-php-multiversion
This docker image provides all PHP versions available in [Ondřej Surý's PPA](https://github.com/oerdnj/deb.sury.org) for development purpose.

It's a key part of php-library-development-toolkit which aims to make development of PHP libraries smooth, even on many PHP versions.

My use case is presently centered around php-cli and I have a lot of work before matching my expectations but using it as a multiversion fpm provider could be interesting also later.

For production purpose I recommend [jtreminio/php-docker](https://github.com/jtreminio/php-docker) image which provides a light image of PHP in any version of the same PPA.