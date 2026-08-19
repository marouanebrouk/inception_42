FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-cli \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

RUN wget https://wordpress.org/latest.tar.gz -P /tmp \
    && tar -xzf /tmp/latest.tar.gz -C /tmp \
    && cp -r /tmp/wordpress/* /var/www/html/ \
    && rm -rf /tmp/latest.tar.gz /tmp/wordpress

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]

CMD ["php-fpm8.2", "-F"]