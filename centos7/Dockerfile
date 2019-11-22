ARG PHP_VERSION=7.1
FROM dustinrue/base-php:${PHP_VERSION} AS builder

ARG PHP_VERSION=7.1
ARG MSMTP_VERSION=1.8.6

USER root
RUN yum groupinstall "Development Tools" -y
RUN yum install wget -y
RUN wget https://marlam.de/msmtp/releases/msmtp-${MSMTP_VERSION}.tar.xz && tar xf msmtp-${MSMTP_VERSION}.tar.xz
RUN cd msmtp-${MSMTP_VERSION} && autoreconf -i && ./configure && make && make install

ARG PHP_VERSION=7.1
FROM  dustinrue/base-php:${PHP_VERSION}

ARG PHP_VERSION=7.1

USER root

COPY --from=builder /usr/local /usr/local

RUN export VERSION=$(echo $PHP_VERSION | sed -E 's/([0-9]).([0-9])/\1\2/g'); echo $VERSION; yum install php-fpm --enablerepo=remi-php${VERSION} -y && yum clean all

RUN mkdir -p /run/php-fpm && \
  chown 33:33 $_ && \
  chown 33:33 /var/log/php-fpm && \
  touch /usr/local/etc/msmtprc && \
  chown 33:33 $_
COPY config/php-fpm.conf /etc/php-fpm.conf
COPY config/www.conf /etc/php-fpm.d/www.conf
RUN echo "post_max_size = 150m" >> /etc/php.d/upload-limits.ini
RUN echo "upload_max_filesize = 150m" >> /etc/php.d/upload-limits.ini

RUN echo 'alias ls="ls --color=auto"' > /etc/profile.d/colorls.sh
COPY entrypoint.sh /entrypoint.sh
RUN ln -s /usr/local/bin/msmtp /usr/sbin/sendmail && chmod +x /entrypoint.sh

USER www-data
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
