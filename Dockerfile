FROM leanlabs/php:1.1.1

VOLUME ["/app"]

ENV VK_CLIENT_ID="111" \
    VK_CLIENT_SECRET="secret" \
    VK_REDIRECT_URI="kubikvest" \
    URI_OAUTH_VK="vk-server"

RUN echo "@stale http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --update \
        php-zlib \
        php-pdo_mysql \
        php-pdo && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/bin/sh", "/app/entrypoint/kubikvest.sh"]

CMD ["php-fpm", "-F", "-d error_reporting=E_ALL", "-d log_errors=ON", "-d error_log=/dev/stdout","-d display_errors=YES"]
