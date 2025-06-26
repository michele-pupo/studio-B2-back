FROM php:8.1-fpm

# Installa dipendenze di sistema
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql

# Installa Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Imposta la directory di lavoro
WORKDIR /var/www/html

# ✅ Copia tutto il codice prima di installare
COPY . .

# Esegui Composer
RUN composer install --no-dev --optimize-autoloader

# Compila asset Vue
RUN npm install && npm run build

# Espone la porta per il server
EXPOSE 8000

# Comando di avvio: migration + serve
CMD ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}"]