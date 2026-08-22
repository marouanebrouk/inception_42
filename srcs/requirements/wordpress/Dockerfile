FROM debian:bullseye

RUN apt-get update && \
    apt-get -y install php7.4 php7.4-mysql php7.4-fpm mariadb-client wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/wordpress_setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress_setup.sh && \
    mkdir -p /run/php

ENTRYPOINT ["wordpress_setup.sh"]

CMD ["/usr/sbin/php-fpm7.4", "--nodaemonize"]