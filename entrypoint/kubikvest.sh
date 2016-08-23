#!/usr/bin/env sh

set -e

echo "env[VK_CLIENT_ID]=$VK_CLIENT_ID" >> /etc/php/php-fpm.conf
echo "env[VK_CLIENT_SECRET]=$VK_CLIENT_SECRET" >> /etc/php/php-fpm.conf
echo "env[VK_REDIRECT_URI]=$VK_REDIRECT_URI" >> /etc/php/php-fpm.conf
echo "env[URI_OAUTH_VK]=$URI_OAUTH_VK" >> /etc/php/php-fpm.conf
echo "env[URL]=$URL" >> /etc/php/php-fpm.conf
echo "env[KEY]=$KEY" >> /etc/php/php-fpm.conf

exec "$@"
