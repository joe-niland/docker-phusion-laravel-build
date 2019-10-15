# Use phusion/baseimage as base image.
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest-amd64

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install packages for Laravel and front-end build process

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND=noninteractive\
    UCF_FORCE_CONFFNEW=1
RUN add-apt-repository -y ppa:ondrej/php && \
  apt-get update && \
  apt-get -y upgrade -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" && \
  apt-get -y -o Dpkg::Options::="--force-confold" install ca-certificates \
  supervisor wget git apache2 php-xdebug rsync \
  libpng-dev \
  libapache2-mod-php7.3 php7.3 pwgen php7.3-apc \
  php7.3-gd php7.3-xml php7.3-mbstring php7.3-curl php7.3-dev php7.3-sybase php7.3-gmp \
  freetds-common libsybdb5 php7.3-mysql php7.3-gettext zip unzip php7.3-zip \
  jq openssh-client
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    npm install -g --silent n gulp-cli yarn && \
    n lts && \
    yarn global add node-sass@4.12.0 && \
    ln -sf /usr/local/n/versions/node/8.2.1/bin/node /usr/bin/node && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    echo "[global]" > /etc/freetds/freetds.conf && \
    echo "tds version = 8.0" >> /etc/freetds/freetds.conf && \
    echo "text size = 20971520" >> /etc/freetds/freetds.conf && \
    echo "client charset = UTF-8" >> /etc/freetds/freetds.conf

# Update CLI PHP to use 7.3
RUN ln -sfn /usr/bin/php7.3 /etc/alternatives/php

# Set PHP timezones to Australia/Sydney
RUN sed -i "s/;date.timezone =/date.timezone = Australia\/Sydney/g" /etc/php/7.3/apache2/php.ini
RUN sed -i "s/;date.timezone =/date.timezone = Australia\/Sydney/g" /etc/php/7.3/cli/php.ini

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# We need Phpunit 5.7 for this to work
RUN php -r "copy('https://phar.phpunit.de/phpunit-5.7.phar', 'phpunit');" && \
    mv phpunit /usr/local/bin

# Set Executable Bit for Phpunit
RUN chmod +x /usr/local/bin/phpunit

# Rewrite enable
RUN a2enmod rewrite

# Configure /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for the app
VOLUME  [ "/app" ]


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
