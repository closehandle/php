#!/usr/bin/env bash
if [[ ! -f /usr/local/etc/php-fpm.d/www.conf ]]; then
    size=$(($(nproc) * 8))
    if (( $size < 8 )); then
        size='8'
    fi

    cat <<EOF>/usr/local/etc/php-fpm.d/www.conf
[www]
user = root
group = root
listen = 0.0.0.0:9000
listen.backlog = -1

pm = static
pm.max_children = $size
pm.max_requests = 1024
request_terminate_timeout = 30
request_slowlog_timeout = 0
EOF
fi

exec php-fpm -R
