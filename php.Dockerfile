FROM php:8.3-fpm

# Install PHP Extensions
RUN docker-php-ext-install pdo pdo_mysql mysqli

RUN pecl install xdebug && docker-php-ext-enable xdebug
