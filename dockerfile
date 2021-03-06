FROM php:8.0.8-fpm-alpine3.14

USER root

#ini rename
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -e; \
         apk add --no-cache \
                coreutils \
                freetype-dev \
                libjpeg-turbo-dev \
                libjpeg-turbo \
                libpng-dev \
                libzip-dev \
                jpeg-dev \
                icu-dev \
                zlib-dev \
                curl-dev \
                imap-dev \
                libxslt-dev libxml2-dev \
                postgresql-dev \
                libgcrypt-dev \
                oniguruma-dev 

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure imap

RUN set -e; docker-php-ext-install -j "$(nproc)" \
                gd soap imap bcmath mbstring iconv curl sockets \
                opcache \
                pdo_pgsql \
                xsl \
                exif \
                mysqli pdo pdo_mysql \
                intl \
                zip

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

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

# install composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# install nodejs
RUN apk add --update nodejs npm

CMD ["/bin/bash", "-c", "php-fpm && nginx -g 'daemon off;'"]