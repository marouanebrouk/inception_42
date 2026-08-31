*This project has been created as part of the 42 curriculum by mbrouk.*

# Inception

## Description

This project is a containerized web platform built with Docker Compose. The goal is to deploy a small but complete stack made of:

- NGINX as the HTTPS entry point
- WordPress as the application and content management layer
- MariaDB as the relational database backend

The system is designed to demonstrate how to build a production-like infrastructure using isolated containers instead of a full virtual machine setup. The project focuses on container orchestration, network isolation, persistent storage, secure configuration, and automation of service initialization.

The stack is configured to expose a WordPress site over HTTPS on a local domain such as `mbrouk.42.fr`, while keeping the database and application logic separated in dedicated containers. The project also shows how environment variables and Docker secrets are used to avoid hardcoding sensitive data in the image or source tree.

## Project overview

The repository contains all the files needed to build and run the three core services:

- `srcs/docker-compose.yml` orchestrates the full stack
- `srcs/requirements/nginx` provides the HTTPS reverse proxy
- `srcs/requirements/wordpress` installs PHP-FPM and WordPress
- `srcs/requirements/mariadb` initializes MariaDB and configures users and permissions
- `Makefile` provides shortcuts to build, start, stop, and clean the environment

## Docker and design choices

### Why Docker?

Docker is used to package each component in a lightweight, reproducible environment. Instead of installing services directly on the host machine, each one runs in its own container with a specific purpose and minimal dependencies. This approach makes the project easier to build, move, and maintain while improving isolation.

### Virtual Machines vs Docker

A virtual machine includes a full guest operating system, which makes it heavier and slower to boot. Docker containers share the host kernel and package only the required application and runtime dependencies. In this project, Docker is a better fit because the services are lightweight, self-contained, and can be orchestrated together with Compose without the overhead of separate VMs.

### Secrets vs Environment Variables

Environment variables are useful for non-sensitive configuration such as domain names, database names, or usernames. Secrets are meant for sensitive information such as passwords and private credentials. In this project, credentials are stored as Docker secrets rather than directly in the Compose file or Docker image. This improves security and keeps sensitive values out of basic environment files and source control.

### Docker Network vs Host Network

Each container runs on a dedicated Docker bridge network named `inception`. This avoids exposing every service directly to the host and keeps the internal service-to-service communication private. The NGINX container communicates with WordPress over the internal Docker network, and WordPress communicates with MariaDB over the same network. A host network would expose ports and services more broadly and reduce control over traffic isolation.

### Docker Volumes vs Bind Mounts

This project uses named volumes configured as bind mounts to keep persistent data on the host filesystem under `/home/mbrouk/data`. This gives the project a predictable, easy-to-manage storage location while still preserving data across container restarts. A pure Docker volume is convenient for ephemeral or portable deployments, but bind mounts are useful when a host path is intentionally chosen for persistence and debugging.

## Instructions

### Requirements

Before running the project, make sure the following are installed on the host machine:

- Docker
- Docker Compose
- A Unix-like environment with `make`
- Access to `sudo` if required by your Docker installation

### Initial setup

1. Create the required secrets in a repository-level `secrets/` directory:

   - `credentials.txt`
   - `db_password.txt`
   - `db_root_password.txt`

2. Create the environment file at `srcs/.env` and provide the required variables for the database and WordPress configuration, such as:

   - `DOMAIN_NAME`
   - `WP_TITLE`
   - `WP_ADMIN_LOGIN`
   - `WP_ADMIN_EMAIL`
   - `WP_USER_LOGIN`
   - `WP_USER_EMAIL`
   - `WP_DATABASE`
   - `WP_DBUSER`

3. Ensure the host domain is resolved locally if you want to use the configured URL. For example, add the following line to `/etc/hosts`:

   ```bash
   127.0.0.1 mbrouk.42.fr
   ```

### Build and run

From the repository root:

```bash
make
```

This target creates the required host directories and launches the stack in detached mode with:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

### Useful commands

```bash
make up
make down
make stop
make start
make clean
make fclean
```

### Check the running services

```bash
docker compose -f srcs/docker-compose.yml ps
```

The expected services are:

- `mariadb`
- `wordpress`
- `nginx`

### Access the site

Open the following URL in a browser:

```text
https://mbrouk.42.fr
```

Because the certificate is self-signed, the browser may warn about security. This is expected for local development and testing.


## Resources

### References

- Docker documentation: https://docs.docker.com/
- Docker tutorial in 2 hours: https://www.youtube.com/watch?v=zJ6WbK9zFpI
- Docker kodekloud labs: https://kodekloud.com/studio/labs/docker
- Docker Compose documentation: https://docs.docker.com/compose/
- PHP-FPM documentation: https://www.php.net/manual/en/install.fpm.php
- Create ssl certificate: https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04

### AI Usage

AI was used in this project to help with:

- understanding the project requirements and expected structure
- drafting the documentation and explaining the architecture
- clarifying the relationship between NGINX, WordPress, and MariaDB in the compose stack

