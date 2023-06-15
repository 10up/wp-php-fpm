#!/bin/bash


cat >> /etc/php-fpm.d/www.conf <<EOF
php_value[session.save_handler] = ${SESSION_HANDLER:-files}
php_value[session.save_path]    = '${SESSION_PATH:-/var/lib/php/sessions}'
EOF
