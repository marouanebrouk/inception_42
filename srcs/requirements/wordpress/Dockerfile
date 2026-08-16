FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-xml \
    php-mbstring \
    php-zip \
    php-intl \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
