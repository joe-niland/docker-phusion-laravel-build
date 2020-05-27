# Use phusion/baseimage as base image.
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest-amd64

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND=noninteractive\
    UCF_FORCE_CONFFNEW=1\
    NODE_VERSION=10\
    PHP_TIMEZONE=Australia\/Sydney\
    BITBUCKET_SSH_KEY=\
    NPM_TOKEN=

# Install packages for Laravel and front-end build process
RUN add-apt-repository -y ppa:ondrej/php && \
  apt-get update && \
  apt-get -y upgrade -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" && \
  apt-get -y -o Dpkg::Options::="--force-confold" install ca-certificates \
  supervisor wget git php-xdebug rsync \
  libpng-dev \
  pwgen php7.2-cli php7.2-common php7.2-apc \
  php7.2-gd php7.2-xml php7.2-mbstring php7.2-curl php7.2-dev php7.2-sybase php7.2-gmp \
  freetds-common libsybdb5 php7.2-mysql php7.2-gettext zip unzip php7.2-zip \
  php7.2-mongodb \
  jq openssh-client

RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g --silent n gulp-cli yarn && \
    n ${NODE_VERSION} && \
    PATH="$PATH" && \
    npm -g i --unsafe-perm node-sass@4.12.0

# Update CLI PHP to use 7.2
RUN ln -sfn /usr/bin/php7.2 /etc/alternatives/php

# Set PHP timezones to Australia/Sydney
RUN sed -i "s?;date.timezone =?date.timezone = ${PHP_TIMEZONE}?g" /etc/php/7.2/cli/php.ini && \
    phpdismod xdebug

# Install composer and composer packages
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&\
    composer global require hirak/prestissimo &&\
    composer global require "phpunit/phpunit:~8.0.0" --prefer-source --no-interaction &&\
    ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

# RUN composer config --list --global

# Add common host keys
RUN touch /root/.ssh/known_hosts &&\
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts &&\
    ssh-keyscan github.com >> /root/.ssh/known_hosts &&\
    ssh-keyscan gitlab.com >> /root/.ssh/known_hosts

# Add volumes for the app
VOLUME  [ "/app" ]

WORKDIR /app

# Clean up APT when done.
RUN apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
