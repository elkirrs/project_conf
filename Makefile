include .env

# MakeFile for Laravel Crash Course

laravel_install: #Create new Laravel project
	@docker-compose exec $(CONTAINER_PHP) composer create-project --prefer-dist laravel/laravel .

key: #generate APP key
	@docker-compose exec $(CONTAINER_PHP) php artisan key:generate

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
	@docker-compose exec $(CONTAINER_PHP) $(SHELL)

connect_db: #Connect to DB container
	@docker-compose exec $(CONTAINER_DB) $(SHELL)

connect_rmq: #Connect to rabbitmq container
	@docker-compose exec $(CONTAINER_RMQ) $(SHELL)

connect_server: #Connect to container_server container
	@docker-compose exec $(CONTAINER_SERVER) $(SHELL)