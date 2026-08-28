#!/bin/bash

DB_PASS=$(cat /run/secrets/db_password)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/${WP_DATABASE}" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1
	mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${WP_DATABASE};
CREATE USER IF NOT EXISTS '${WP_DBUSER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${WP_DATABASE}.* TO '${WP_DBUSER}'@'%';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
fi

exec mysqld
