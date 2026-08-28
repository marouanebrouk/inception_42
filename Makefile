NAME = inception42

COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/mbrouk/data

all:
	mkdir -p $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/mariadb
	$(COMPOSE) up -d --build

up:
	mkdir -p $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/mariadb
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

clean:
	$(COMPOSE) down -v


fclean: clean
	docker system prune -af
	sudo rm -rf /home/mbrouk/data

re: fclean all

.PHONY: all up down stop start clean fclean re