#!/usr/bin/env bash
if [[ ! -f /usr/local/etc/php-fpm.d/www.conf ]]; then
    size=$(( $(nproc) * 4 ))
    if (( $size < 4 )); then
        size='4'
    fi

    cat <<EOF>/usr/local/etc/php-fpm.d/www.conf
[www]
user = root
group = root
listen = $FPM_BIND:$FPM_PORT
listen.backlog = -1

pm = dynamic
pm.start_servers = $size
pm.min_spare_servers = $size
pm.max_spare_servers = $(( $size * 4 ))
pm.max_children = $(( $size * 8 ))
pm.max_requests = 1024
request_terminate_timeout = 30
request_slowlog_timeout = 0
EOF
fi

exec php-fpm -R
