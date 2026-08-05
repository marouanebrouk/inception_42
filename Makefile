NAME = inception42

COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up --build

up:
	$(COMPOSE) up --build

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

re: fclean all

.PHONY: all up down stop start clean fclean re