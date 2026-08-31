# Developer documentation

## Purpose

This document explains how to set up, build, and maintain the Inception project as a developer. It focuses on prerequisites, configuration, Docker Compose usage, container management, and persistent data storage.

## Prerequisites

Before starting, make sure the host machine has:

- Docker installed and running
- Docker Compose available
- `make` installed
- a Linux or Unix-like environment
- permissions to create directories and run Docker commands

If your Docker setup requires `sudo`, use it when running `docker` and `docker compose` commands.

## Environment configuration

### Required files

The project expects:

- `srcs/.env` for runtime environment variables
- `secrets/credentials.txt`
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`

These files are intentionally not committed to the Git repository and are created locally as part of setup.

### Example environment setup

Create the `.env` file under `srcs/` and define the required WordPress and MariaDB values. A minimal example looks like this:

```env
DOMAIN_NAME=mbrouk.42.fr
WP_TITLE=Inception
WP_ADMIN_LOGIN=admin
WP_ADMIN_EMAIL=admin@example.com
WP_USER_LOGIN=user
WP_USER_EMAIL=user@example.com
WP_DATABASE=wordpress
WP_DBUSER=wpuser
```

The project also expects the secret files to contain the login and password values used by the services.

### Secrets layout

```text
secrets/
├── credentials.txt
├── db_password.txt
├── db_root_password.txt
```

The values in these files are loaded with Docker secrets and used by the MariaDB and WordPress initialization scripts.

## Build and launch

The project includes a `Makefile` to streamline the workflow.

### Build the full stack

```bash
make
```

This command does the following:

- creates the persistent host directories under `/home/mbrouk/data`
- starts the services in detached mode
- builds the Docker images if needed

### Start only the stack

```bash
make up
```

### Stop the stack

```bash
make stop
```

### Remove containers

```bash
make down
```

### Clean the project data

```bash
make clean
```

This removes the Compose-defined resources, including volumes if configured to be deleted.

### Full reset

```bash
make fclean
```

This resets the stack more aggressively and removes Docker cache artifacts and project data.

## Docker Compose workflow

The stack is defined in:

```text
srcs/docker-compose.yml
```

The compose file defines three main services:

- `mariadb`
- `wordpress`
- `nginx`

The services use:

- an internal Docker network named `inception`
- Docker secrets for sensitive values
- bind-mounted persistent directories for data
- a multi-container architecture for separation of concerns

### Common commands

Start in detached mode:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Inspect running containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

Stop containers:

```bash
docker compose -f srcs/docker-compose.yml stop
```

Remove containers and networks:

```bash
docker compose -f srcs/docker-compose.yml down
```

## Container and volume management

### Inspect running containers

```bash
docker ps
```

### Open a shell inside a running container

```bash
docker exec -it nginx bash
```

or:

```bash
docker exec -it wordpress bash
```

### Inspect Docker volumes

```bash
docker volume ls
```

### Remove orphaned or unused resources

```bash
docker system prune -af
```

## Where the data is stored

The project uses bind mounts for persistent storage under `/home/mbrouk/data`.

The current Compose configuration mounts:

- `/home/mbrouk/data/mariadb` for MariaDB data
- `/home/mbrouk/data/wordpress` for WordPress files

This means the project data persists on the host filesystem even if the containers are stopped or recreated.

### Example locations

```text
/home/mbrouk/data/
├── mariadb/
└── wordpress/
```

These directories are created by the Makefile and are used by the Docker volumes defined in `srcs/docker-compose.yml`.
