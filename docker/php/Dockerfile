FROM php:8.3-fpm-alpine

# System deps
RUN apk add --no-cache \
    git zip unzip icu-dev libpng-dev libjpeg-turbo-dev freetype-dev oniguruma-dev libzip-dev bash

# PHP extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo pdo_mysql mbstring intl zip
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install gd

# Opcache (optional but good)
RUN docker-php-ext-install opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configure PHP-FPM for dev
RUN { \
  echo "memory_limit=512M"; \
  echo "upload_max_filesize=32M"; \
  echo "post_max_size=32M"; \
  echo "max_execution_time=120"; \
} > /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html
