#!/bin/bash

# Enable Data Dog if DD_ENABLED is set to true
if [ ${DD_ENABLED:-false} = "true" ]; then
  # echo "DD_ENABLED is true. Sending traces to ${DD_AGENT_HOST:-localhost}:${DD_TRACE_AGENT_PORT:-8126}"
  ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace.ini /etc/php/${PHP_VERSION}/cli/conf.d/98-ddtrace.ini
  ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace.ini /etc/php/${PHP_VERSION}/fpm/conf.d/98-ddtrace.ini

  if [ "${DD_PROFILING_ENABLED:-true}" = "false" ]; then
    echo "datadog.profiling.enabled = 0" >> /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini
  fi

  ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-ddtrace-customizations.ini
  ln -s /etc/php/${PHP_VERSION}/mods-available/ddtrace-customizations.ini /etc/php/${PHP_VERSION}/fpm/conf.d/99-ddtrace-customizations.ini
fi
