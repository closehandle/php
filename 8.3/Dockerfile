FROM php:8.3-fpm-alpine

RUN apk --update --no-cache upgrade && \
    apk --update --no-cache add bash

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions
RUN install-php-extensions \
    apcu-stable \
    bcmath-stable \
    bz2-stable \
    exif-stable \
    gd-stable \
    gmp-stable \
    igbinary-stable \
    imagick-stable \
    imap-stable \
    intl-stable \
    ldap-stable \
    mysqli-stable \
    opcache-stable \
    pcntl-stable \
    pdo_mysql-stable \
    redis-stable \
    sockets-stable \
    ssh2-stable \
    zip-stable

ADD entrypoint.sh /usr/bin/entrypoint.sh
ADD docker.conf   /usr/local/etc/php-fpm.d/docker.conf
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/conf.d/php.ini
RUN rm -f /usr/local/etc/php-fpm.d/www.conf
RUN rm -f /usr/local/etc/php-fpm.d/www.conf.default
RUN rm -f /usr/local/etc/php-fpm.d/zz-docker.conf
RUN sed -E -i 's|^;date.timezone =.*|date.timezone = Asia/Shanghai|g' /usr/local/etc/php/conf.d/php.ini
RUN sed -E -i 's|^post_max_size = .*|post_max_size = 1024M|g' /usr/local/etc/php/conf.d/php.ini
RUN sed -E -i 's|^upload_max_filesize = .*|upload_max_filesize = 1024M|g' /usr/local/etc/php/conf.d/php.ini
RUN sed -E -i 's|^max_execution_time = .*|max_execution_time = 30|g' /usr/local/etc/php/conf.d/php.ini
RUN sed -E -i 's|^short_open_tag = .*|short_open_tag = On|g' /usr/local/etc/php/conf.d/php.ini
RUN sed -E -i 's|^expose_php = .*|expose_php = Off|g' /usr/local/etc/php/conf.d/php.ini

CMD ["/usr/bin/entrypoint.sh"]
