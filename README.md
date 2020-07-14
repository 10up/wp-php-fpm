# CentOS - wp-php-fpm

> This image extends the `base-php` image to include `php-fpm` focussing on serving WordPress.  This image also includes the New Relic PHP agent which is disabled by default.

[![Support Level](https://img.shields.io/badge/support-active-green.svg)](#support-level) [![MIT License](https://img.shields.io/github/license/10up/wp-php-fpm.svg)](https://github.com/10up/wp-php-fpm/blob/master/LICENSE)

## Usage

This image runs just php-fpm and expects that files are located at `/var/www/html`. They can be mounted or copied there using an init container. Running this image might look like this:

```
docker run -d --name phpfpm \
  -v /var/www/html:/var/www/html
  10up/wp-php-fpm
```

This image is configured with MSMTP for handling email. It can only be configured to talk to an even smarter smart host meaning it cannot be configured with authentication of any sort. To configure MSMTP pass the following environment variables

* `MAILER_HOST=<your mailer host>`
* `MAILER_PORT=<your mailer hosts port>`

The entrypoint script will then configure MSMTP properly.

### Using New Relic Agent

By default, the New Relic Agent is installed but disabled. To enable it you must mount a config file at `/etc/php.d/newrelic.ini` (or similar) with at least the following items:

```
newrelic.enabled = true
newrelic.appname = "YOUR APP NAME"
newrelic.license = "YOUR LICENSE KEY"
newrelic.daemon.address = "HOST:PORT"
```

The configuration assumes you will have the New Relic Daemon running elsewhere as a separate container or process. You can read more about it at https://docs.newrelic.com/docs/agents/php-agent/advanced-installation/docker-other-container-environments-install-php-agent#install-diff-containers.

## Building

This project takes advantage of custom build phase hooks as described at https://docs.docker.com/docker-hub/builds/advanced/. When setting up builds on docker hub create automated builds with rules to build for the master branch for each PHP version you want built. Currently this image is built with 5.6, 7.0, 7.1, 7.2, 7.3 and 7.4.

## Support Level

**Active:** 10up is actively working on this, and we expect to continue work for the foreseeable future including keeping tested up to the most recent version of WordPress.  Bug reports, feature requests, questions, and pull requests are welcome.

## Like what you see?

<p align="center">
<a href="http://10up.com/contact/"><img src="https://10updotcom-wpengine.s3.amazonaws.com/uploads/2016/10/10up-Github-Banner.png" width="850"></a>
</p>
