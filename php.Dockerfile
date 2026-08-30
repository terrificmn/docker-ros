FROM php:8.4-fpm

# Install System Dependencies needed for compiling extensions
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libxml2-dev zip unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP Extensions 
## already inside the php image
RUN docker-php-ext-install pdo pdo_mysql mysqli gd
## install third party extentions and enable it 
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js + npm (needed for breeze:install vue to run npm install)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*