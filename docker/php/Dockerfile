FROM php:8.3-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libicu-dev libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libzip-dev \
 && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" \
    pdo pdo_mysql mbstring intl zip gd opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Dev PHP settings
RUN { \
  echo "memory_limit=512M"; \
  echo "upload_max_filesize=32M"; \
  echo "post_max_size=32M"; \
  echo "max_execution_time=120"; \
} > /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html
