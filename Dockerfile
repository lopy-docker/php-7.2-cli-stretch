# build:
#
# docker build -t registry.cn-hongkong.aliyuncs.com/lopy-dev/php7.2-cli .

# This dockerfile uses the ubuntu image
# VERSION 2 - EDITION 1
# Author: docker_user
# Command format: Instruction [arguments / command ] ..

# Base image to use, this nust be set as the first line
FROM php:7.2-cli

# Maintainer: docker_user <docker_user at email.com> (@docker_user)
MAINTAINER zengyu 284141050@qq.com

#


# swoole
RUN pecl install swoole && docker-php-ext-enable swoole

RUN pecl install apcu && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini \
    && echo "apc.ttl=10" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini \
    && echo "apc.use_request_time=0" >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini


RUN docker-php-ext-install -j$(nproc) pdo_mysql
#RUN docker-php-ext-install pdo_mysql

RUN pecl install inotify && docker-php-ext-install inotify

# Commands when creating a new container
CMD ["php","-a"]
