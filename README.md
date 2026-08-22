# Inception 42

This project builds a small WordPress infrastructure with Docker Compose.

## Current Progress

The MariaDB and WordPress services are working together:

```text
WordPress PHP-FPM -> MariaDB
```

NGINX has not been added yet. It will become the HTTPS entry point later.

## Project Structure

```text
srcs/
├── .env
├── docker-compose.yml
├── requirements/
│   ├── mariadb/
│   │   ├── Dockerfile
│   │   ├── conf/50-server.cnf
│   │   └── tools/mariadb_start.sh
│   └── wordpress/
│       ├── Dockerfile
│       ├── conf/www.conf
│       └── tools/wordpress_setup.sh
└── secrets/
    ├── credentials.txt
    ├── db_password.txt
    └── db_root_password.txt
```

## MariaDB

The MariaDB image is based on Debian Bullseye and installs the MariaDB server.
The image copies a custom server configuration and starts MariaDB with
`mariadb_start.sh`.

On the first start, the script:

1. Reads the database passwords from Docker secrets.
2. Initializes the MariaDB data directory.
3. Creates the database from `MYSQL_DATABASE`.
4. Creates `MYSQL_USER` and grants it access to the database.
5. Sets the local MariaDB root password.
6. Starts the MariaDB server.

MariaDB data is stored in the persistent `mariadb_data` volume.

## WordPress

The WordPress image is based on Debian Bullseye and installs:

- PHP 7.4
- PHP-FPM
- PHP MySQL support
- MariaDB client tools
- WP-CLI

`wordpress_setup.sh` performs first-run installation only when
`/var/www/html/wp-config.php` does not exist. It downloads WordPress, creates
`wp-config.php`, installs WordPress, creates the configured users, and assigns
ownership to `www-data`.

PHP-FPM listens on port `9000` inside the Docker network. It is not exposed to
the host yet; NGINX will connect to it later.

WordPress files are stored in the persistent `wordpress_data` volume.

## Environment Variables

The file `srcs/.env` is loaded by Docker Compose:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
DOMAIN_NAME=localhost
WP_TITLE=My WordPress Site
WP_ADMIN_LOGIN=admin
WP_ADMIN_EMAIL=admin@example.com
WP_USER_LOGIN=author
WP_USER_EMAIL=author@example.com
```

These values configure the MariaDB database and the initial WordPress site and
users.

## Docker Secrets

Passwords are kept in local files under `srcs/secrets/` and mounted inside the
containers by Docker Compose:

- `db_password.txt`: MariaDB application-user password
- `db_root_password.txt`: MariaDB root password
- `credentials.txt`: WordPress administrator password

The secret files are ignored by Git through `.gitignore`. Replace the example
passwords with private values before using this project outside a local test
environment.

## Starting the Services

From the project root:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Check the service status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Stop the services without deleting data:

```bash
docker compose -f srcs/docker-compose.yml down
```

To remove the containers and persistent volumes and initialize everything again:

```bash
docker compose -f srcs/docker-compose.yml down -v
docker compose -f srcs/docker-compose.yml up -d --build
```

The `down -v` command deletes the MariaDB and WordPress data.

## Verification Tests

Check that WordPress is installed:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  wp --path=/var/www/html core is-installed --allow-root
```

Check the database:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  wp --path=/var/www/html db check --allow-root
```

Check the configured site URL:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  wp --path=/var/www/html option get siteurl --allow-root
```

List WordPress users:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  wp --path=/var/www/html user list --field=user_login --allow-root
```

Check that PHP-FPM is running:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress pgrep -a php-fpm
```

At the current stage, browser access is not available because NGINX and HTTPS
have not been configured yet.
