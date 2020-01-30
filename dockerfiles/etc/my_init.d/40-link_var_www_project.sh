#!/bin/sh
if ["$PHPMV_RUNNING_USER" == 'travis']; then
    # mainly for the /spec dir
    mkdir -p /var/www/project
    git clone https://github.com/jclaveau/docker-php-multiversion /var/www/project
fi

# Redirects the default vhost to the project workdir
ln -s "$PHPMV_WORKDIR" /var/www/project
