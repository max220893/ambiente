FROM php:8.0.8-fpm-alpine3.14

USER root

#ini rename
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN apk add openrc

RUN apk add nano

RUN apk add nginx && \
    mkdir -p /etc/nginx/sites-enabled /run/nginx && \
    ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

RUN apk add --no-cache certbot-nginx

# ADD ./conf.d /etc/nginx/conf.d
# ADD ./php-fpm /usr/local/etc/php-fpm.d/

RUN apk add --no-cache --upgrade bash

RUN rm /usr/local/etc/php-fpm.d/zz-docker.conf

# install drivers sqlsrv
RUN wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.1.1-1_amd64.apk
RUN wget https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.1.1-1_amd64.apk
RUN apk add --allow-untrusted msodbcsql17_17.5.1.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools_17.5.1.1-1_amd64.apk
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS unixodbc-dev
RUN pecl install pdo_sqlsrv
RUN docker-php-ext-enable pdo_sqlsrv
RUN apk del .phpize-deps
RUN rm msodbcsql17_17.5.1.1-1_amd64.apk
RUN rm mssql-tools_17.5.1.1-1_amd64.apk

#sodium
RUN docker-php-ext-enable sodium

RUN apk add --no-cache php8 \
    php8-common \
    php8-fpm \
    php8-pdo \
    php8-opcache \
    php8-zip \
    php8-phar \
    php8-iconv \
    php8-cli \
    php8-curl \
    php8-openssl \
    php8-mbstring \
    php8-tokenizer \
    php8-fileinfo \
    php8-json \
    php8-xml \
    php8-xmlwriter \
    php8-simplexml \
    php8-dom \
    php8-pdo_mysql \
    php8-pdo_sqlite \
    php8-tokenizer \
    php8-pecl-redis


# install composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# install nodejs
RUN apk add --update nodejs npm

CMD ["/bin/bash", "-c", "php-fpm && nginx -g 'daemon off;'"]