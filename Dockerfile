FROM php:8.2-fpm

# Dependencias de sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    nginx \
    libpq-dev \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
 && docker-php-ext-install pdo pdo_mysql mbstring zip gd bcmath calendar \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Código de la app
COPY . .

# Instalar dependencias PHP (sin dev)
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-calendar

# Permisos para Laravel/Krayin
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Configuración Nginx para Laravel
RUN rm -f /etc/nginx/sites-enabled/default
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Nginx debe poder leer el código
RUN chown -R www-data:www-data /var/www/html

# Exponer puerto HTTP
EXPOSE 80

# Ejecutar php-fpm y nginx
CMD service php-fpm start && nginx -g 'daemon off;'
