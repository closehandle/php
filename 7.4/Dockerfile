FROM debian:bullseye-slim AS builder

# prevent Debian's PHP packages from being installed
# https://github.com/docker-library/php/pull/542
RUN set -eux; \
    { \
        echo 'Package: php*'; \
        echo 'Pin: release *'; \
        echo 'Pin-Priority: -1'; \
    } > /etc/apt/preferences.d/no-debian-php

# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
        autoconf \
        dpkg-dev \
        file \
        g++ \
        gcc \
        libc-dev \
        make \
        pkg-config \
        re2c

# persistent / runtime deps
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        ca-certificates \
        curl \
        xz-utils \
    ; \
    rm -rf /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
    [ ! -d /var/www/html ]; \
    mkdir -p /var/www/html; \
    chown www-data:www-data /var/www/html; \
    chmod 1777 /var/www/html

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

ENV PHP_VERSION 7.4.33
ENV PHP_URL="https://www.php.net/distributions/php-7.4.33.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.4.33.tar.xz.asc"
ENV PHP_SHA256="924846abf93bc613815c55dd3f5809377813ac62a9ec4eb3778675b82a27b927"

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg; \
    rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /usr/src; \
    cd /usr/src; \
    \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
        echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
        curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
        export GNUPGHOME="$(mktemp -d)"; \
        for key in $GPG_KEYS; do \
            gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
        done; \
        gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libargon2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libreadline-dev \
        libsodium-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev \
    ; \
    \
    export \
        CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
# https://github.com/php/php-src/blob/d6299206dd828382753453befd1b915491b741c6/configure.ac#L1496-L1511
        PHP_BUILD_PROVIDER='https://github.com/docker-library/php' \
        PHP_UNAME='Linux - Docker' \
    ; \
    docker-php-source extract; \
    cd /usr/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# https://bugs.php.net/bug.php?id=74125
    if [ ! -d /usr/include/curl ]; then \
        ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    fi; \
    ./configure \
        --build="$gnuArch" \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        \
# make sure invalid --configure-flags are fatal errors instead of just warnings
        --enable-option-checking=fatal \
        \
# https://github.com/docker-library/php/issues/439
        --with-mhash \
        \
# https://github.com/docker-library/php/issues/822
        --with-pic \
        \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
        --enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
        --enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash
        --with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
        --with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
        --with-pdo-sqlite=/usr \
        --with-sqlite3=/usr \
        \
        --with-curl \
        --with-iconv \
        --with-openssl \
        --with-readline \
        --with-zlib \
        \
# https://github.com/bwoebi/phpdbg-docs/issues/1#issuecomment-163872806 ("phpdbg is primarily a CLI debugger, and is not suitable for debugging an fpm stack.")
        --disable-phpdbg \
        \
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear")
        --with-pear \
        \
        --with-libdir="lib/$debMultiarch" \
        \
        --disable-cgi \
        \
        --enable-fpm \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
    ; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    find \
        /usr/local \
        -type f \
        -perm '/0111' \
        -exec sh -euxc ' \
            strip --strip-all "$@" || : \
        ' -- '{}' + \
    ; \
    make clean; \
    \
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
    cp -v php.ini-* "$PHP_INI_DIR/"; \
    \
    cd /; \
    docker-php-source delete; \
    \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    \
# update pecl channel definitions https://github.com/docker-library/php/issues/443
    pecl update-channels; \
    rm -rf /tmp/pear ~/.pearrc; \
    \
# smoke test
    php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www/html

RUN set -eux; \
    cd /usr/local/etc; \
    if [ -d php-fpm.d ]; then \
        # for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
        sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
        cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
    else \
        # PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
        mkdir php-fpm.d; \
        cp php-fpm.conf.default php-fpm.d/www.conf; \
        { \
            echo '[global]'; \
            echo 'include=etc/php-fpm.d/*.conf'; \
        } | tee php-fpm.conf; \
    fi; \
    { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
        echo; \
        echo '[www]'; \
        echo '; php-fpm closes STDOUT on startup, so sending logs to /proc/self/fd/1 does not work.'; \
        echo '; https://bugs.php.net/bug.php?id=73886'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
        echo 'decorate_workers_output = no'; \
    } | tee php-fpm.d/docker.conf; \
    { \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = 9000'; \
    } | tee php-fpm.d/zz-docker.conf; \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
    { \
        echo '; https://github.com/docker-library/php/issues/878#issuecomment-938595965'; \
        echo 'fastcgi.logging = Off'; \
    } > "$PHP_INI_DIR/conf.d/docker-fpm.ini"

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000
CMD ["php-fpm"]

FROM builder

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
    sed -E -i 's|^;?date.timezone ?= ?.*|date.timezone = Asia/Shanghai|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?post_max_size ?= ?.*|post_max_size = 100M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?upload_max_filesize ?= ?.*|upload_max_filesize = 100M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?max_execution_time ?= ?.*|max_execution_time = 120|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?max_input_time ?= ?.*|max_input_time = 30|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?memory_limit ?= ?.*|memory_limit = 512M|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?mysqli.max_persistent ?= ?.*|mysqli.max_persistent = 4|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?short_open_tag ?= ?.*|short_open_tag = Off|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?expose_php ?= ?.*|expose_php = Off|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.enable ?= ?.*|opcache.enable = 1|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.memory_consumption ?= ?.*|opcache.memory_consumption = 512|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.interned_strings_buffer ?= ?.*|opcache.interned_strings_buffer = 128|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.max_accelerated_files ?= ?.*|opcache.max_accelerated_files = 1000000|g' /usr/local/etc/php/conf.d/php.ini && \
    sed -E -i 's|^;?opcache.validate_timestamps ?= ?.*|opcache.validate_timestamps = 0|g' /usr/local/etc/php/conf.d/php.ini

ENV FPM_BIND=0.0.0.0
ENV FPM_PORT=9000

CMD ["/usr/bin/entrypoint.sh"]
