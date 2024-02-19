FROM php:8.3-fpm

RUN apt update && \
    apt full-upgrade -y && \
    apt autoremove --purge -y && \
    apt clean

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/bin/
RUN chmod +x /usr/bin/install-php-extensions && install-php-extensions \
    apcu \
    bcmath \
    bz2 \
    exif \
    gd \
    gmp \
    igbinary \
    imap \
    intl \
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
RUN chmod +x /usr/bin/entrypoint.sh && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/conf.d/php.ini && \
    rm -f /usr/local/etc/php-fpm.d/www.conf && \
    rm -f /usr/local/etc/php-fpm.d/www.conf.default && \
    rm -f /usr/local/etc/php-fpm.d/zz-docker.conf && \
    sed -E -i 's|^;date.timezone =.*|date.timezone = Asia/Shanghai|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^post_max_size = .*|post_max_size = 1024M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^upload_max_filesize = .*|upload_max_filesize = 1024M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^max_execution_time = .*|max_execution_time = 30|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^short_open_tag = .*|short_open_tag = On|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^expose_php = .*|expose_php = Off|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;opcache.enable=1|opcache.enable = 1|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;opcache.memory_consumption=128|opcache.memory_consumption = 512|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;opcache.interned_strings_buffer=8|opcache.interned_strings_buffer = 128|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;opcache.max_accelerated_files=10000|opcache.max_accelerated_files = 1000000|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;opcache.validate_timestamps=1|opcache.validate_timestamps = 0|g' /usr/local/etc/php/conf.d/php.ini && \

CMD ["/usr/bin/entrypoint.sh"]
