#!/bin/bash

cat > /usr/local/etc/msmtprc <<EOF
account default
host ${MAILER_HOST:-mailcatcher}
port ${MAILER_PORT:-1025}
auto_from on
EOF

if [ ! -z "${SESSION_HANDLER}" ]; then
cat >> /etc/php-fpm.d/www.conf <<EOF
php_value[session.save_handler] = ${SESSION_HANDLER}
php_value[session.save_path]    = '${SESSION_PATH}'
EOF
else
cat >> /etc/php-fpm.d/www.conf <<EOF
php_value[session.save_handler] = files
php_value[session.save_path]    = '/var/lib/php/sessions'
EOF
fi


if [ ! -z "${NR_LICENSE_KEY}" ]; then
cat > /etc/php.d/newrelic.ini <<EOF
newrelic.enabled = true
newrelic.daemon.address = ${NR_HOST}
newrelic.license = ${NR_LICENSE_KEY}
newrelic.appname = ${NR_APP_NAME:-wordpress}
EOF
fi

# changing this will break dependent images
exec /usr/sbin/php-fpm -F
