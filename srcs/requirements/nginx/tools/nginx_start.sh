#!/bin/bash

if [ ! -f /etc/ssl/certs/nginx.crt ]; then

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx.key \
		-out /etc/ssl/certs/nginx.crt \
		-subj "/CN=mbrouk.42.fr"
fi

exec nginx -g "daemon off;"