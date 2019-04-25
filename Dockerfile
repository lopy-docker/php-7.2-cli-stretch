# build:
#

# This dockerfile uses the ubuntu image
# VERSION 2 - EDITION 1
# Author: docker_user
# Command format: Instruction [arguments / command ] ..

# Base image to use, this nust be set as the first line
FROM php:7.2-cli-stretch

# Maintainer: docker_user <docker_user at email.com> (@docker_user)
MAINTAINER zengyu 284141050@qq.com

RUN echo "change apt source" \
    && echo "deb http://ftp.debian.org/debian stretch main contrib non-free" >/etc/apt/sources.list \
    && echo "deb http://ftp.debian.org/debian stretch-updates main contrib non-free" >>/etc/apt/sources.list \
    && echo "deb http://security.debian.org stretch/updates main contrib non-free" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y sudo \ 
    unzip \ 
    unrar \ 
    proxychains \ 
    zlib1g-dev \ 
    procps inetutils-ping \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && sed -i 's/socks4/#socks4/g' /etc/proxychains.conf \
    && sed -i '$a\socks5 	172.17.0.1 1080' /etc/proxychains.conf \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean && apt-get autoremove && apt-get autoclean

#
RUN docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install zip

# #
# RUN pecl install inotify && docker-php-ext-enable inotify

# # swoole
# RUN pecl install swoole && docker-php-ext-enable swoole

RUN pecl install redis inotify swoole \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis inotify swoole

# apcu
RUN pecl install apcu && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini \
    && echo "apc.ttl=10" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini \
    && echo "apc.use_request_time=0" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini


RUN useradd debian  -s /bin/bash -m -k /etc/skel \
    && echo "debian  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# composer
RUN echo 'install composer' \
    && cd /usr/local/bin/ \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar composer \
    && sudo -u debian composer global require 'codeception/codeception'
#    && sudo -u debian ./composer.phar global require 'composer/composer:dev-master' \


# update env
RUN echo "update env" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/root/.bashrc" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/home/debian/.bashrc" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/root/.profile" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/home/debian/.profile" \
    && echo "export PATH=\$PATH:/home/debian/.composer/vendor/bin" >> "/etc/profile" 


# support zh-cn
ENV LANG C.UTF-8

# Commands when creating a new container
CMD ["php","-a"]
