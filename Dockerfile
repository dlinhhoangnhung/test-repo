# GIAI ĐOẠN 1: Build Assets (NPM)
FROM node:20-alpine AS assets-builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# GIAI ĐOẠN 2: Chạy ứng dụng (PHP)
FROM php:8.4-fpm-alpine

# Cài đặt extension hệ thống cần thiết cho Aureus ERP
RUN apk add --no-cache \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    linux-headers \
    $PHPIZE_DEPS \
    git \
    zip \
    unzip \
    netcat-openbsd

# Cài đặt các Extension PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql opcache gd zip intl mbstring bcmath pcntl

# Hỗ trợ Redis
RUN pecl install redis && docker-php-ext-enable redis

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# TỐI ƯU CACHE COMPOSER: 
COPY composer.json composer.lock ./
COPY plugins/ ./plugins/

# Cài đặt dependency mà không chạy script và không tạo autoloader (tránh lỗi thiếu file artisan)
RUN composer install --no-dev --no-interaction --no-scripts --ignore-platform-reqs --no-autoloader

# Copy toàn bộ mã nguồn PHP còn lại
COPY . .

# Sau khi đã có đầy đủ mã nguồn (bao gồm file artisan), mới tạo autoloader tối ưu
RUN composer dump-autoload --optimize --no-scripts

# Copy kết quả đã build (JS/CSS) từ GIAI ĐOẠN 1 sang thư mục public
COPY --from=assets-builder /app/public/build ./public/build

# Thiết lập quyền hạn cho các thư mục quan trọng
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Cài đặt script entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
