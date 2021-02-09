# multi stage build to install msmtp. I am aware that msmtp is available
# in the centos 7 repos but I want it consistent with the centos 8 build,
# don't @ me
ARG PHP_VERSION=7.1
FROM 10up/base-php:${PHP_VERSION} AS builder

ARG PHP_VERSION=7.1
ARG MSMTP_VERSION=1.8.14

USER root
RUN yum groupinstall "Development Tools" -y
RUN yum install wget -y
RUN wget https://marlam.de/msmtp/releases/msmtp-${MSMTP_VERSION}.tar.xz && tar xf msmtp-${MSMTP_VERSION}.tar.xz
RUN cd msmtp-${MSMTP_VERSION} && autoreconf -i && ./configure && make && make install

ARG PHP_VERSION=7.1
FROM  10up/base-php:${PHP_VERSION}

ARG PHP_VERSION=7.1

USER root

COPY --from=builder /usr/local /usr/local

RUN export VERSION=$(echo $PHP_VERSION | sed -E 's/([0-9]).([0-9])/\1\2/g'); yum install php-fpm --enablerepo=remi-php${VERSION} -y && yum clean all

RUN export NR_AGENT_VERSION=$(curl https://download.newrelic.com/php_agent/release/ | grep "linux.tar" | sed -E 's/.*release\/(.+)\".*/\1/'); curl -so - https://download.newrelic.com/php_agent/release/${NR_AGENT_VERSION} | tar zxf - && \
  cd ${NR_AGENT_VERSION:0:-7} && NR_INSTALL_SILENT=1 NR_INSTALL_USE_CP_NOT_LN=1 ./newrelic-install install && \
  rm -rf /tmp/nrinstall* && \
  mv /etc/php.d/newrelic.ini /etc/php.d/10-newrelic.ini && \
  echo 'newrelic.daemon.start_timeout = "5s"' >> /etc/php.d/10-newrelic.ini && \
  echo 'newrelic.daemon.app_connect_timeout = "15s"' >> /etc/php.d/10-newrelic.ini && \
  echo 'newrelic.logfile = /dev/stderr' >> /etc/php.d/10-newrelic.ini && \
  echo 'newrelic.loglevel = warning' >> /etc/php.d/10-newrelic.ini && \
  echo 'newrelic.enabled = false' >> /etc/php.d/10-newrelic.ini

RUN mkdir -p /run/php-fpm && \
  chown 33:33 $_ && \
  chown 33:33 /var/log/php-fpm && \
  touch /usr/local/etc/msmtprc && \
  chown 33:33 $_ && \
  touch /etc/php.d/newrelic.ini && \
  chown 33:33 $_

COPY config/php-fpm.conf /etc/php-fpm.conf
COPY config/www.conf /etc/php-fpm.d/www.conf
COPY config/docker-opcache.ini /etc/php.d/docker-opcache.ini

RUN echo "post_max_size = 150m" >> /etc/php.d/upload-limits.ini
RUN echo "upload_max_filesize = 150m" >> /etc/php.d/upload-limits.ini
RUN echo "catch_workers_output = yes" >> /etc/php-fpm.d/www.conf
RUN chown 33:33 /etc/php-fpm.d/www.conf

RUN echo 'alias ls="ls --color=auto"' > /etc/profile.d/colorls.sh
COPY entrypoint.sh /entrypoint.sh
RUN ln -s /usr/local/bin/msmtp /usr/sbin/sendmail && chmod +x /entrypoint.sh

USER www-data
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
