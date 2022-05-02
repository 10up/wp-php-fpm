ARG PHP_VERSION=7.4

# Set a BASE_IMAGE CI var to specify a different base image without a tag
ARG BASE_IMAGE=10up/base-php
FROM ${BASE_IMAGE}:${PHP_VERSION}-ubuntu

ARG PHP_VERSION=7.4
ARG TARGETPLATFORM

USER root

RUN set -x; apt-get update; apt install php${PHP_VERSION}-fpm msmtp curl -y && apt clean all; rm -rf /var/lib/apt/lists/* 

RUN \
  if [ "${TARGETPLATFORM}" = "linux/arm64" ] ; then exit 0; fi ; export NR_AGENT_VERSION=$(curl https://download.newrelic.com/php_agent/release/ | grep "linux.tar" | sed -E 's/.*release\/(.+)\".*/\1/'); curl -so - https://download.newrelic.com/php_agent/release/${NR_AGENT_VERSION} | tar zxf - && \
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
RUN phpdismod opcache && phpenmod docker-opcache upload-limits opcache 
RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm

RUN echo 'alias ls="ls --color=auto"' > /etc/profile.d/colorls.sh
COPY entrypoint.sh /entrypoint.sh
RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail && chmod +x /entrypoint.sh

USER www-data
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
