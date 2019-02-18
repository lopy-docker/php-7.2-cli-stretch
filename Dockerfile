# build:
#

# This dockerfile uses the ubuntu image
# VERSION 2 - EDITION 1
# Author: docker_user
# Command format: Instruction [arguments / command ] ..

# Base image to use, this nust be set as the first line
FROM lopydev/php-7.2-cli-stretch

# Maintainer: docker_user <docker_user at email.com> (@docker_user)
MAINTAINER zengyu 284141050@qq.com

RUN echo "change apt source" \
    && echo "deb http://ftp.debian.org/debian stretch main contrib non-free" >/etc/apt/sources.list \
    && echo "deb http://ftp.debian.org/debian stretch-updates main contrib non-free" >>/etc/apt/sources.list \
    && echo "deb http://security.debian.org stretch/updates main contrib non-free" >>/etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y sudo \ 
    && apt-get install -y unzip \ 
    && apt-get install -y unrar \ 
    && apt-get clean && apt-get autoclean 


RUN docker-php-ext-install -j$(nproc) pdo_mysql

RUN pecl install inotify && docker-php-ext-enable inotify

# swoole
RUN pecl install swoole && docker-php-ext-enable swoole

# apcu
RUN pecl install apcu && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini \
    && echo "apc.ttl=10" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini \
    && echo "apc.use_request_time=0" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini


# composer
RUN mkdir /var/www \ 
    && chown -R www-data /var/www \
    && cd /usr/local/bin \
    && curl -sS https://getcomposer.org/installer | php \
    && composer.phar global require 'composer/composer:dev-master' \
    && composer.phar global require 'codeception/codeception'


# update env
RUN echo "update env" \
    && echo "export PATH=\$PATH:/root/.composer/vendor/bin" >> /root/.bashrc \
    && echo "export PATH=\$PATH:/root/.composer/vendor/bin" >> /root/.profile \
    && echo "export PATH=\$PATH:/root/.composer/vendor/bin" >> /etc/profile 


# support zh-cn
ENV LANG C.UTF-8

# Commands when creating a new container
CMD ["php","-a"]
