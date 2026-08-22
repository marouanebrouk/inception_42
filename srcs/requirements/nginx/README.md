# NGINX Service

NGINX is the public entry point for the Inception infrastructure. It accepts
HTTPS requests and forwards PHP requests to the WordPress PHP-FPM container.

```text
Browser -> NGINX HTTPS -> WordPress PHP-FPM -> MariaDB
```

## Files

```text
nginx/
├── Dockerfile
├── conf/
│   └── default
└── tools/
    └── nginx_start.sh
```

## Dockerfile

The image is based on Debian Bullseye and installs:

- NGINX
- OpenSSL

The Dockerfile copies the NGINX server configuration and startup script into
the image. NGINX runs in the foreground with `daemon off`, which keeps it as
the main container process.

## HTTPS Certificate

`nginx_start.sh` creates a self-signed TLS certificate the first time the
container starts:

- Certificate: `/etc/ssl/certs/nginx.crt`
- Private key: `/etc/ssl/private/nginx.key`
- Certificate name: `mbrouk.42.fr`
- Validity: 365 days

Because the certificate is self-signed, browsers display a security warning.
For local testing, the warning can be accepted. The certificate is generated
inside the container and is not stored in the project repository.

## NGINX Configuration

The `conf/default` file configures one HTTPS server:

```nginx
listen 443 ssl;
server_name mbrouk.42.fr;
```

The site root is `/var/www/html`, which is the WordPress shared volume.
Requests are handled as follows:

- Existing files and directories are served directly.
- Other requests are redirected to WordPress `index.php`.
- PHP files are sent to `wordpress:9000` using FastCGI.
- `SCRIPT_FILENAME` tells PHP-FPM which WordPress file to execute.

PHP-FPM is reached through the internal Docker network. Port `9000` is not
published to the host.

## Docker Compose Integration

The NGINX service in `srcs/docker-compose.yml`:

- Builds from `requirements/nginx`.
- Starts after the WordPress service.
- Publishes container port `443` as host port `443`.
- Mounts the `wordpress_data` volume read-only at `/var/www/html`.

The read-only mount lets NGINX serve WordPress files without modifying them.
WordPress itself keeps the writable version of the same volume.

## Local Domain

The NGINX configuration uses `mbrouk.42.fr`. To make this name resolve to the
local machine, add this line to `/etc/hosts`:

```text
127.0.0.1 mbrouk.42.fr
```

The site can then be opened at:

```text
https://mbrouk.42.fr
```

The WordPress `DOMAIN_NAME` value in `srcs/.env` should match this hostname:

```env
DOMAIN_NAME=mbrouk.42.fr
```

## Starting NGINX

From the project root, build and start the complete stack:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Check the services:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected services:

```text
mariadb
wordpress
nginx
```

## Verification Tests

Validate the NGINX configuration inside the container:

```bash
docker exec nginx nginx -t
```

Expected result:

```text
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Test HTTPS locally while ignoring the self-signed certificate:

```bash
curl -k -I https://localhost
```

Or test the configured domain:

```bash
curl -k -I https://mbrouk.42.fr
```

A working setup returns an HTTP response such as:

```text
HTTP/1.1 200 OK
```

Check that WordPress still reaches MariaDB:

```bash
docker compose -f srcs/docker-compose.yml exec wordpress \
  wp --path=/var/www/html db check --allow-root
```

The expected result is:

```text
Success: Database checked.
```
