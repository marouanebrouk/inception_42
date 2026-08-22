#!/bin/bash

set -e

# hardcoded values :
# DB_NAME="wordpress"
# DB_USER="wpuser"
# DB_PASS="password"
# ROOT_PASS="rootpassword"

# env
# MYSQL_DATABASE=wordpress
# MYSQL_USER=wpuser
# MYSQL_PASSWORD=password
# MYSQL_ROOT_PASSWORD=rootpassword

DB_NAME="$MYSQL_DATABASE"
DB_USER="$MYSQL_USER"
DB_PASS="$MYSQL_PASSWORD"
ROOT_PASS="$MYSQL_ROOT_PASSWORD"


DB_PATH="/var/lib/mysql"

# Create the necessary directories for MariaDB to run and set the appropriate permissions. The /run/mysqld directory is used by MariaDB to store its socket file and PID file, and it needs to be owned by the mysql user and have the correct permissions for MariaDB to function properly.
#systemd not used in this container, so we need to create the /run/mysqld directory manually and set the correct ownership and permissions for it. This is necessary for MariaDB to start and run properly in the container.
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chmod 755 /run/mysqld

if [ ! -d "$DB_PATH/mysql" ]; then
	echo "Initializing MariaDB..."

	mariadb-install-db --user=mysql --datadir="$DB_PATH"
    # Start MariaDB in the background and wait for it to be ready before creating the database and user
	mysqld --user=mysql --datadir="$DB_PATH" &
	PID="$!"

	echo "Waiting for MariaDB to start..."
    # Wait until MariaDB is ready to accept connections and then create the database and user 
	until mysqladmin ping --silent > /dev/null 2>&1
	do
		sleep 1
	done

    # Create the database and user with the specified credentials , and grant privileges to the user on the database. Also, set the root password and flush privileges to apply changes. then stop the temporary MariaDB instance and wait for it to exit before starting the main MariaDB process.
	mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
    #how to stop the temporary MariaDB instance and wait for it to exit before starting the main MariaDB process.
    #answer : you can stop the temporary MariaDB instance by using the `mysqladmin` command with the `shutdown` option, and then wait for the process to exit using the `wait` command with the process ID (PID) of the temporary MariaDB instance. Here's how you can do it:
    echo "Stopping temporary MariaDB..."

	mysqladmin -u root -p"${ROOT_PASS}" shutdown
    # Wait for the temporary MariaDB instance to exit
	wait "$PID"

	echo "MariaDB initialized."
fi

echo "Starting MariaDB..."
# Start the main MariaDB process in the foreground using `exec` to replace the current shell process with the `mysqld` command. This ensures that the container will keep running as long as the MariaDB process is running.
exec mysqld --user=mysql --datadir="$DB_PATH"
echo " MariaDB started."
