FROM php:8.2-fpm

RUN apt update && \
    apt full-upgrade -y && \
    apt autoremove --purge -y && \
    apt clean

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/bin/
RUN chmod +x /usr/bin/install-php-extensions && install-php-extensions \
    apcu \
    bcmath \
    bitset \
    bz2 \
    exif \
    gd \
    gmp \
    grpc \
    igbinary \
    imagick \
    imap \
    intl \
    ioncube_loader \
    ldap \
    lz4 \
    lzf \
	msgpack \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    redis \
    soap \
    sockets \
    ssh2 \
    sync \
	tidy \
    uuid \
	yaml \
    zip \
    zstd

ADD entrypoint.sh /usr/bin/entrypoint.sh
ADD docker.conf   /usr/local/etc/php-fpm.d/docker.conf
RUN chmod +x /usr/bin/entrypoint.sh && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/conf.d/php.ini && \
    rm -f /usr/local/etc/php-fpm.d/www.conf && \
    rm -f /usr/local/etc/php-fpm.d/www.conf.default && \
    rm -f /usr/local/etc/php-fpm.d/zz-docker.conf && \
    sed -E -i 's|^;?date.timezone =.*|date.timezone = Asia/Shanghai|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?post_max_size = .*|post_max_size = 100M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?upload_max_filesize = .*|upload_max_filesize = 100M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?max_execution_time = .*|max_execution_time = 120|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?short_open_tag = .*|short_open_tag = Off|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?expose_php = .*|expose_php = Off|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.enable=1|opcache.enable = 1|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.memory_consumption=128|opcache.memory_consumption = 512|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.interned_strings_buffer=8|opcache.interned_strings_buffer = 128|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.max_accelerated_files=10000|opcache.max_accelerated_files = 1000000|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.validate_timestamps=1|opcache.validate_timestamps = 0|g' /usr/local/etc/php/conf.d/php.ini

ENV FPM_BIND=0.0.0.0
ENV FPM_PORT=9000

CMD ["/usr/bin/entrypoint.sh"]
