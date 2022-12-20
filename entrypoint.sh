#!/bin/bash

cat > /etc/msmtprc <<EOF
account default
host ${MAILER_HOST:-mailcatcher}
port ${MAILER_PORT:-1025}
auto_from on
EOF

cat >> /etc/php-fpm.d/www.conf <<EOF
php_value[session.save_handler] = ${SESSION_HANDLER:-files}
php_value[session.save_path]    = '${SESSION_PATH:-/var/lib/php/sessions}'
EOF

# Enable New Relic if there is a license key
if [ ! -z "${NR_LICENSE_KEY}" ]; then
cat > /etc/php/${PHP_VERSION}/mods-available/newrelic.ini <<EOF
extension = "newrelic.so"

[newrelic]
newrelic.enabled = true
newrelic.framework.wordpress.hooks = true
newrelic.daemon.address = ${NR_HOST}
newrelic.license = ${NR_LICENSE_KEY}
newrelic.appname = ${NR_APP_NAME:-wordpress}
EOF
else
cat > /etc/php/${PHP_VERSION}/mods-available/newrelic.ini <<EOF
extension = "newrelic.so"

[newrelic]
newrelic.enabled = false
EOF
fi

# Enable Data Dog if DD_ENABLED is set to true
if [ ${DD_ENABLED:-false} = "true" ]; then
# echo "DD_ENABLED is true. Sending traces to ${DD_AGENT_HOST:-localhost}:${DD_TRACE_AGENT_PORT:-8126}"
ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace.ini /etc/php/${PHP_VERSION}/cli/conf.d/98-ddtrace.ini
ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace.ini /etc/php/${PHP_VERSION}/fpm/conf.d/98-ddtrace.ini

#cat > /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini <<EOF
#datadog.trace.agent_host = ${DD_AGENT_HOST:-localhost}
#datadog.trace.agent_port = ${DD_TRACE_AGENT_PORT:-8126}
#EOF

if [ "${DD_PROFILING_ENABLED:-true}" = "false" ]; then
  echo "datadog.profiling.enabled = 0" >> /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini
fi

ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-ddtrace-customizations.ini
ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini /etc/php/${PHP_VERSION}/fpm/conf.d/99-ddtrace-customizations.ini
fi

# changing this will break dependent images
exec /usr/sbin/php-fpm -F
