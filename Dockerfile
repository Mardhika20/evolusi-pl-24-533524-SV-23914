FROM php:8.3-cli

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libsqlite3-dev \
    && docker-php-ext-install pdo pdo_sqlite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Salin dan verifikasi dependency terlebih dahulu
COPY composer.json composer.lock ./

RUN composer validate --no-check-publish \
    && composer install \
       --no-dev \
       --no-interaction \
       --prefer-dist \
       --optimize-autoloader \
       --no-scripts

# Source code baru disalin setelah dependency
COPY . .

RUN composer dump-autoload --optimize \
    && mkdir -p storage/framework/cache \
       storage/framework/sessions \
       storage/framework/views \
       storage/logs \
       bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
