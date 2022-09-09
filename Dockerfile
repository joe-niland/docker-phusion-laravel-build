# Use phusion/baseimage as base image.
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:focal-1.2.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install packages for Laravel and front-end build process

ENV DEBIAN_FRONTEND=noninteractive \
    UCF_FORCE_CONFFNEW=1 \
    NODE_VERSION=14 \
    NODE_SASS_VERSION=6.0.1 \
    PHP_TIMEZONE=Australia\/Sydney \
    PHP_VERSION=7.3

# Install packages
RUN add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get -y upgrade -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" && \
    apt-get -y -o Dpkg::Options::="--force-confold" install ca-certificates \
    wget \
    libpng-dev \
    pwgen php$PHP_VERSION-cli php$PHP_VERSION-common php$PHP_VERSION-apc \
    php$PHP_VERSION-gd php$PHP_VERSION-xml php$PHP_VERSION-mbstring php$PHP_VERSION-curl php$PHP_VERSION-dev php$PHP_VERSION-sybase php$PHP_VERSION-gmp \
    freetds-common libsybdb5 php$PHP_VERSION-mysql php$PHP_VERSION-gettext zip unzip php$PHP_VERSION-zip \
    jq openssh-client
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g --silent n gulp-cli yarn && \
    n ${NODE_VERSION} && \
    PATH="$PATH" && \
    npm -g i --unsafe-perm node-sass@$NODE_SASS_VERSION

# Update CLI PHP to use $PHP_VERSION
RUN ln -sfn /usr/bin/php$PHP_VERSION /etc/alternatives/php

# Set PHP timezones to Australia/Sydney
RUN sed -i "s?;date.timezone =?date.timezone = ${PHP_TIMEZONE}?g" /etc/php/$PHP_VERSION/cli/php.ini

# Get Composer bin from official image
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Run composer and phpunit installation.
RUN composer global require "phpunit/phpunit:~9.0.0" --prefer-dist --no-interaction && \
    ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

# Add volumes for the app
VOLUME [ "/app" ]

# Clean up APT when done.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app