# 10up/wp-php-fpm

> This image extends the `base-php` image to include `php-fpm` focussing on serving WordPress.  This image also includes the New Relic PHP agent as well as the Data Dog integration. Both are disabled by default and must be enabled by passing the correct ENV vars which are detailed below.

[![Support Level](https://img.shields.io/badge/support-active-green.svg)](#support-level) [![MIT License](https://img.shields.io/github/license/10up/wp-php-fpm.svg)](https://github.com/10up/wp-php-fpm/blob/master/LICENSE)

## Usage

This image runs just php-fpm and expects that files are located at `/var/www/html`. They can be mounted or copied there using an init container. Running this image might look like this:

```
docker run -d --name phpfpm \
  -v /var/www/html:/var/www/html
  10up/wp-php-fpm:<php version>-ubuntu
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

### Using Data Dog Integration

By default, the Data Dog integration is installed but disabled. To enable it you can pass:

* `DD_ENABLED` (required) - set this to true to enable the Data Dog integration. False by default.
* `DD_PROFILING_ENABLED` (optional) - set this to true to enable profiling. True by default. **NOTE** Profiling is not available on PHP < 7.1.

See official Data Dog documentation for additional configuration options.

### Session Variables

By default, php-fpm is set to use files method as session handlers and session files are stored in `/var/lib/php/sessions`. This can be changed to any other session handler by providing the environment variables, like for memcached use the following environment variables:

```
SESSION_HANDLER = memcached
SESSION_PATH    = '127.0.0.1:11211'
``` 

Change `SESSION_PATH` value to memcached server's IP address or host record

## Building

This image uses GitHub actions. For it to work you must create an environment called Build and then create the following variables:

`IMAGE_NAME` - The name of the image. For example, 10up sets this value to `10up/wp-php-fpm`. You must set this to your own Docker hub namespace.
`DOCKERHUB_USERNAME` - The username for the Docker hub account you wish to push images to.
`DOCKERHUB_TOKEN` - The token to use against your Docker hub account.
`BASE_IMAGE` - The base image to build this image from. Typically this is `10up/base-php`. If you are also customizing the base-php image then setting this variable will ensure wp-php-fpm is built from your customized base image.

### A note about branches

The default workflow will create images differently depending on the branch. `develop` will create and push an image to Docker hub tagged as `10up/wp-php-fpm:<php version>-ubuntu-dev` while the `trunk` branch will create and push an image called `10up/wp-php-fpm:<php version>-ubuntu`. This behavior is defined and can be modified in `.github/workflows/build.yaml`.

## Support Level

**Active:** 10up is actively working on this, and we expect to continue work for the foreseeable future including keeping tested up to the most recent version of WordPress.  Bug reports, feature requests, questions, and pull requests are welcome.

## Like what you see?

<p align="center">
<a href="http://10up.com/contact/"><img src="https://10up.com/uploads/2016/10/10up-Github-Banner.png" width="850"></a>
</p>
