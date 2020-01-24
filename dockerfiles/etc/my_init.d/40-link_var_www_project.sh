#!/bin/sh
# Redirects the default vhost to the project workdir
ln -s "$PHPMV_WORKDIR" /var/www/project
