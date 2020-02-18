FROM crossworth/composer-parallel as vendor

COPY database /app/database

COPY composer.json /app/composer.json
COPY composer.lock /app/composer.lock

RUN cd /app/ && composer install \
    --optimize-autoloader \
    --no-dev \
    --no-ansi \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-progress \
    --no-scripts \
    --prefer-dist

# Final image
FROM crossworth/php73-fpm-alpine-exts

COPY --from=vendor --chown=www-data:www-data /app/vendor /var/www/html/vendor
COPY --chown=www-data:www-data . /var/www/html
COPY run.sh /var/www/run.sh

# chmod start script and remove nginx files
RUN chmod +x /var/www/run.sh && rm -rf /var/www/nginx

CMD ["sh", "/var/www/run.sh"]