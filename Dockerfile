FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    libpng-dev libjpeg-dev libonig-dev libxml2-dev libzip-dev mariadb-client

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy app files
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www && chmod -R 755 /var/www

# Expose port
EXPOSE 8000

# ❗ Runtime setup (moved here)
CMD php artisan config:clear && \
    php artisan key:generate && \
    php artisan migrate --force && \
    php artisan storage:link && \
    php artisan serve --host=0.0.0.0 --port=8000
