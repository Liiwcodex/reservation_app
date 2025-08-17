FROM php:8.3-fpm

# System deps
RUN apt-get update && apt-get install -y \ 
    git unzip libonig-dev libzip-dev libssl-dev libcurl4-openssl-dev \ 
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pcntl zip

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
