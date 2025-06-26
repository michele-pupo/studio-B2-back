# 1) Base image PHP con Composer e estensioni
FROM php:8.1-fpm

# 2) Installa dipendenze di sistema per Laravel + Postgres + Node
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql

# 3) Installa Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4) Imposta working directory
WORKDIR /var/www/html

# 5) Copia solo i file di dipendenze per sfruttare la cache
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# 6) Copia il resto del codice
COPY . .

# 7) Installa JS dependencies e build assets
RUN npm install && npm run build

# 8) Espone la porta su cui Laravel serve
EXPOSE 8000

# 9) Comando di avvio: esegue migration e serve
# Utilizza la variabile PORT se definita, altrimenti 8000
CMD ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port ${PORT:-8000}"]