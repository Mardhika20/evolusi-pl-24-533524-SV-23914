
# ==========================================
# STAGE 1: BUILD
# ==========================================
FROM php:8.3.27-cli-alpine AS builder

WORKDIR /var/www

# Instalasi dependency untuk proses build
RUN apk add --no-cache \
    git \
    unzip \
    sqlite-dev \
    && docker-php-ext-install pdo_sqlite

# Mengambil Composer versi spesifik
COPY --from=composer:2.8.12 /usr/bin/composer /usr/bin/composer

# Menyalin file dependency terlebih dahulu
COPY composer.json composer.lock ./

# Instalasi dependency Laravel
RUN composer validate --no-check-publish \
    && composer install \
        --no-dev \
        --no-interaction \
        --prefer-dist \
        --optimize-autoloader \
        --no-scripts

# Menyalin source code aplikasi
COPY . .

# Menyiapkan autoload dan direktori Laravel
RUN composer dump-autoload --optimize \
    && mkdir -p \
        storage/framework/cache \
        storage/framework/sessions \
        storage/framework/views \
        storage/logs \
        bootstrap/cache

# ==========================================
# STAGE 2: RUNTIME
# ==========================================
FROM php:8.3.27-cli-alpine AS runtime

WORKDIR /var/www

# Instalasi ekstensi SQLite dan alat healthcheck
RUN apk add --no-cache \
    sqlite-dev \
    curl \
    && docker-php-ext-install pdo_sqlite \
    && apk del sqlite-dev

# Membuat pengguna non-root
RUN addgroup -S laravel \
    && adduser -S -G laravel laravel

# Menyalin aplikasi dari builder
COPY --from=builder /var/www /var/www

# Menyiapkan folder dan izin akses Laravel
RUN mkdir -p \
        storage/framework/cache \
        storage/framework/sessions \
        storage/framework/views \
        storage/logs \
        bootstrap/cache \
    && chown -R laravel:laravel \
        /var/www/storage \
        /var/www/bootstrap/cache \
        /var/www/database \
    && chmod -R u+rwX \
        /var/www/storage \
        /var/www/bootstrap/cache \
        /var/www/database

# Menjalankan container sebagai non-root
USER laravel

# Port aplikasi Laravel
EXPOSE 8000

# Pemeriksaan kesehatan container
HEALTHCHECK --interval=30s --timeout=10s \
    --start-period=30s --retries=3 \
    CMD curl --fail --silent --output /dev/null \
    http://127.0.0.1:8000/ || exit 1

# Menjalankan Laravel
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
