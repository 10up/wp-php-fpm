ARG PHP_VERSION=8.2

# Set a BASE_IMAGE CI var to specify a different base image without a tag
ARG BASE_IMAGE=ghcr.io/10up/base-php
FROM ${BASE_IMAGE}:${PHP_VERSION}-ubuntu

ARG PHP_VERSION=8.2
ARG TARGETPLATFORM

ENV PHP_VERSION=${PHP_VERSION}

USER root

RUN apt-get update; apt install php${PHP_VERSION}-fpm msmtp curl -y && apt clean all; rm -rf /var/lib/apt/lists/* 

# Routine to install newrelic agent
RUN \
  if [[ "${TARGETPLATFORM}" = "linux/arm64" ]] || [[ "$(uname -m)" = "aarch64" ]]; then exit 0; fi ; export NR_AGENT_VERSION="newrelic-php5-9.20.0.310-linux.tar.gz"; curl -so - https://download.newrelic.com/php_agent/archive/9.20.0.310/${NR_AGENT_VERSION} | tar zxf - && \
  cd newrelic-php* && NR_INSTALL_SILENT=1 NR_INSTALL_USE_CP_NOT_LN=1 ./newrelic-install install && \
  rm -rf /tmp/nrinstall* && \
  echo 'newrelic.daemon.start_timeout = "5s"' >> /etc/php/${PHP_VERSION}/mods-available/newrelic.ini && \
  echo 'newrelic.daemon.app_connect_timeout = "15s"' >> /etc/php/${PHP_VERSION}/mods-available/newrelic.ini && \
  echo 'newrelic.logfile = /dev/stderr' >> /etc/php/${PHP_VERSION}/mods-available/newrelic.ini && \
  echo 'newrelic.loglevel = warning' >> /etc/php/${PHP_VERSION}/mods-available/newrelic.ini && \
  echo 'newrelic.enabled = false' >> /etc/php/${PHP_VERSION}/mods-available/newrelic.ini && \
  mkdir -p /var/log/newrelic && \
  chown 33:33 /var/log/newrelic && \
  chown 33:33 /etc/php/${PHP_VERSION}/mods-available/newrelic.ini && \
  rm -f /etc/php/*/*/conf.d/newrelic.ini && \
  phpenmod newrelic

# Routine to install Data Dog agent
# https://docs.datadoghq.com/tracing/trace_collection/dd_libraries/php/?tab=containers
# You must set DD_AGENT_HOST and DD_TRACE_AGENT_PORT to point at your DD Agent
# We also clean up whatever this config file layout is
RUN \
  curl -LO https://github.com/DataDog/dd-trace-php/releases/download/0.82.0/datadog-setup.php -o /tmp/datadog-setup.php && \
  if [[ ${PHP_VERSION} = "5.6" ]] || [[ ${PHP_VERSION} = "7.0" ]]; then php datadog-setup.php --php-bin=all; else php datadog-setup.php --enable-profiling --php-bin=all; fi && \
  rm -f /tmp/datadog-setup.php && \ 
  mv /etc/php/${PHP_VERSION}/cli/conf.d/98-ddtrace.ini /etc/php/${PHP_VERSION}/mods-available/ddtrace.ini && \
  rm -f /etc/php/${PHP_VERSION}/fpm/conf.d/98-ddtrace.ini

RUN \
  mkdir -p /run/php-fpm && \
  chown 33:33 /run/php-fpm && \
  touch /etc/msmtprc && \
  chown 33:33 /etc/msmtprc && \
  touch /var/log/php${PHP_VERSION}-fpm.log && \
  chown 33:33 /var/log/php${PHP_VERSION}-fpm.log && \
  ln -s /etc/php/${PHP_VERSION}/fpm/pool.d/ /etc/php-fpm.d

COPY config/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
COPY config/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY config/docker-opcache.ini /etc/php/${PHP_VERSION}/mods-available/docker-opcache.ini

RUN echo "post_max_size = ${UPLOAD_LIMIT}" >> /etc/php/${PHP_VERSION}/mods-available/upload-limits.ini
RUN echo "upload_max_filesize = ${UPLOAD_LIMIT}" >> /etc/php/${PHP_VERSION}/mods-available/upload-limits.ini
RUN echo "catch_workers_output = yes" >> /etc/php-fpm.d/www.conf
RUN chown 33:33 /etc/php-fpm.d/www.conf
RUN \
  chown 33:33 /etc/php/${PHP_VERSION}/cli/conf.d && \
  chown 33:33 /etc/php/${PHP_VERSION}/fpm/conf.d && \
  chown 33:33 /etc/php/${PHP_VERSION}/mods-available
RUN phpdismod opcache && phpenmod docker-opcache upload-limits opcache 
RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm

RUN echo 'alias ls="ls --color=auto"' > /etc/profile.d/colorls.sh
COPY entrypoint.sh /entrypoint.sh
RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail && chmod +x /entrypoint.sh

USER www-data
WORKDIR /var/www/html
CMD ["/entrypoint.sh"]
