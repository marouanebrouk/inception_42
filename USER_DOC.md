# User documentation

This project deploys a small web stack composed of:

- NGINX: receives HTTPS requests and serves the website
- WordPress: hosts the application and administration panel
- MariaDB: stores the WordPress data and configuration

The goal is to provide a secure and isolated website environment running locally in Docker containers.

## Services provided by the stack

The stack exposes a WordPress site and a database backend. In practice, you can:

- visit the public website over HTTPS
- log in to the WordPress administration panel
- manage content, plugins, and themes through WordPress
- store blog or site data in MariaDB

The services run together through Docker Compose and communicate through an internal private network, so they are isolated from the host environment unless explicitly exposed.

## Start the project

From the repository root, run:

```bash
make
```

This command creates the required directories and starts the stack in detached mode.

You can also start it explicitly with:

```bash
make up
```

If you want to rebuild the images before starting:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

## Stop the project

To stop the containers:

```bash
make stop
```

To stop and remove the container resources:

```bash
make down
```

To fully delete data and unused Docker artifacts:

```bash
make clean
```

To reset everything and fully prune Docker:

```bash
make fclean
```

## Accessing the website

Once the project is running, open the following URL in your browser:

```text
https://mbrouk.42.fr
```

Because the site uses a self-signed certificate, your browser may display a warning. This is normal for a local development setup. You can proceed after confirming the exception.

## Accessing the administration panel

The WordPress administrator panel is available at:

```text
https://mbrouk.42.fr/wp-admin
```

Use the credentials defined in your project configuration and secrets. The admin login and password are stored in your environment and secret files and should not be committed to the repository.

## Locating and managing credentials

The project keeps sensitive values outside the source tree:

- `srcs/.env` contains configuration values such as domain and WordPress settings
- `secrets/` contains private text files such as database passwords and admin credentials

Typical files are:

```text
secrets/
├── credentials.txt
├── db_password.txt
├── db_root_password.txt
```

These files are used by Docker secrets and by the application startup scripts. They should be treated as sensitive information.

## Check that services are running correctly

Use:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected running services:

- `mariadb`
- `wordpress`
- `nginx`

You can also inspect logs with:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

To verify NGINX is accepting requests:

```bash
curl -k -I https://localhost
```

or:

```bash
curl -k -I https://mbrouk.42.fr
```

A successful response should return a status such as `HTTP/1.1 200 OK`.

## Troubleshooting quick checks

If the site is not available:

1. confirm the containers are running
2. check the logs
3. ensure the domain is present in `/etc/hosts`
4. verify the secret and environment files are configured properly

Example `/etc/hosts` entry:

```bash
127.0.0.1 mbrouk.42.fr
```

