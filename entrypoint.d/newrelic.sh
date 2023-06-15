#!/bin/bash


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
