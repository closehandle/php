FROM php:8.1-fpm-alpine

RUN apk --no-cache upgrade && \
    apk --no-cache add bash

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/bin/
RUN chmod +x /usr/bin/install-php-extensions && install-php-extensions \
    apcu \
    bcmath \
    bz2 \
    exif \
    gd \
    gmp \
    igbinary \
    imagick \
    imap \
    intl \
    ioncube_loader \
    ldap \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    redis \
    sockets \
    ssh2 \
    zip

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
