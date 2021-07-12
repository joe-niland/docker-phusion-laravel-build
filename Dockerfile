# Use phusion/baseimage as base image.
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:focal-1.0.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install packages for Laravel and front-end build process

ENV DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=1 NODE_VERSION=14 NODE_SASS_VERSION=6.0.1 PHP_TIMEZONE=Australia\/Sydney

# Install packages
RUN add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get -y upgrade -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" && \
    apt-get -y -o Dpkg::Options::="--force-confold" install ca-certificates \
        supervisor wget git php-xdebug rsync \
        libpng-dev \
        pwgen php7.4-cli php7.4-common php7.4-apc \
        php7.4-gd php7.4-xml php7.4-mbstring php7.4-curl php7.4-dev php7.4-sybase php7.4-gmp \
        freetds-common libsybdb5 php7.4-mysql php7.4-gettext zip unzip php7.4-zip \
        jq openssh-client
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g --silent n gulp-cli yarn && \
    n ${NODE_VERSION} && \
    PATH="$PATH" && \
    npm -g i --unsafe-perm node-sass@$NODE_SASS_VERSION

# Update CLI PHP to use 7.4
RUN ln -sfn /usr/bin/php7.4 /etc/alternatives/php

# Set PHP timezones to Australia/Sydney
RUN sed -i "s?;date.timezone =?date.timezone = ${PHP_TIMEZONE}?g" /etc/php/7.4/cli/php.ini && \
    phpdismod xdebug

# Add composer
# RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
#     php composer-setup.php && \
#     php -r "unlink('composer-setup.php');" && \
#     mv composer.phar /usr/local/bin/composer

# Get Composer bin from official image
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Run composer and phpunit installation.
RUN composer global require "phpunit/phpunit:~9.0.0" --prefer-source --no-interaction
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

# Add volumes for the app
VOLUME [ "/app" ]

# Clean up APT when done.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

