FROM debian:bookworm


RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]

#installing mariaDB
#sudo apt install mariadb-server -y

#checking mariadb status
#sudo systemctl status mariadb


#1. Stop the service
    #sudo systemctl stop mariadb
#2. Remove the packages
    #sudo apt purge mariadb-server mariadb-client mariadb-common -y
#3. Remove packages that are no longer needed
    #sudo apt autoremove --purge -y
#4. Delete the database files

    #⚠️ This permanently deletes all databases.
    #sudo rm -rf /var/lib/mysql

#5. Delete configuration files
    #sudo rm -rf /etc/mysql
#6. Remove logs (optional)
    #sudo rm -rf /var/log/mysql
    #sudo rm -rf /var/log/mariadb
#7. Update package cache
    #sudo apt clean
#8. Verify it is gone
    #mariadb --version
#or
#mysql --version

#You should get something like:
#bash: mariadb: command not found
#or
#bash: mysql: command not found





#sudo service --status-all

#RUNNING MARIADB
#sudo mariadb
# show databases;
# show tables;
# desc users;
# select * from users;
# insert into users (username, email,status) VALUES ('','',''),('','','');
# select from users where status = 'active';
