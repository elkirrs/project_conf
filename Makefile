include .env

# MakeFile for Laravel Crash Course

laravel_install: #Create new Laravel project
	@docker exec -it $(CONTAINER_PHP) composer create-project --prefer-dist laravel/laravel .

clear: #Clear cache and config
    @docker exec -it  $(CONTAINER_PHP) php artisan config:clear

key: #generate APP key
	@docker exec -it  $(CONTAINER_PHP) php artisan key:generate

ownership: #Set ownership
	@sudo chown $(USER):$(USER) . -R

# Work in containers

up: #start docker containers @docker-compose up -d
	@docker-compose up -d

build: #build docker container @docker-compose build
	@docker-compose build

down: #stop docker containers
	@docker-compose down

start: #start docker containers @docker-compose start
	@docker-compose start

stop: #stop docker containers @docker-compose stop
	@docker-compose stop

restart: #restart docker containers @docker-compose restart
	@docker-compose restart

show: #show docker's containers
	@sudo docker ps

connect_php: #Connect to APP container
	@docker exec -it $(CONTAINER_PHP) $(SHELL)

connect_db: #Connect to DB container
	@docker exec -it $(CONTAINER_DB) $(SHELL)

connect_rmq: #Connect to rabbitmq container
	@docker exec -it $(CONTAINER_RMQ) $(SHELL)

connect_server: #Connect to server container
	@docker exec -it $(CONTAINER_SERVER) $(SHELL)

connect_go: #Connect to golang container
	@docker exec -it $(CONTAINER_GOLANG) $(SHELL)

connect_node: #Connect to node container
	@docker exec -it $(CONTAINER_NODE) $(SHELL)

npm_install: #Install dependency
	@docker exec -it $(CONTAINER_NODE) npm install

npm_build: #build file project --development
	@docker exec -it $(CONTAINER_NODE) npm run dev

npm_build_prod: #build file project --production
	@docker exec -it $(CONTAINER_NODE) npm run prod