include .env


# Install app
.PHONY: laravel_i
laravel_i: #Create new Laravel project. Last version
	@docker exec -it $(CONTAINER_PHP) composer create-project --prefer-dist laravel/laravel .

.PHONY: vue_i
vue_i: #Create new vue project
	@docker exec -it $(CONTAINER_VUE) vue create .

.PHONY: npm_i
npm_i: #Install js dependency
	@docker exec -it $(CONTAINER_VUE) npm install

.PHONY: composer_i
composer_i: #Install php dependency
	@docker exec -it $(CONTAINER_PHP) composer install

.PHONY: composer_du
composer_du: # Composer dump autoload
	@docker exec -it $(CONTAINER_PHP) compose du
#-----------------------------------------------------------------------------------------------------------------------


# Work in containers
.PHONY: up
up: #start docker containers @docker-compose up -d
	@docker-compose up -d

.PHONY: build
build: #build docker container @docker-compose build
	@docker-compose build

.PHONY: down
down: #stop and remove docker containers @docker-compose down
	@docker-compose down

.PHONY: start
start: #start docker containers @docker-compose start
	@docker-compose start

.PHONY: stop
stop: #stop docker containers @docker-compose stop
	@docker-compose stop

.PHONY: restart
restart: #restart docker containers @docker-compose restart
	@docker-compose restart
#-----------------------------------------------------------------------------------------------------------------------


#Connect container
.PHONY: connect_php
connect_php: #Connect to php container
	@docker exec -it $(CONTAINER_PHP) $(SHELL)

.PHONY: connect_psql
connect_psql: #Connect to DB container
	@docker exec -it $(CONTAINER_POSTGRES) $(SHELL)

.PHONY: connect_rmq
connect_rmq: #Connect to rabbitmq container
	@docker exec -it $(CONTAINER_RMQ) $(SHELL)

.PHONY: connect_server
connect_server: #Connect to server container
	@docker exec -it $(CONTAINER_SERVER) $(SHELL)

.PHONY: connect_go
connect_go: #Connect to golang container
	@docker exec -it $(CONTAINER_GOLANG) $(SHELL)

.PHONY: connect_vue
connect_vue: #Connect to vue container
	@docker exec -it $(CONTAINER_VUE) $(SHELL)

.PHONY: connect_mongo
connect_mongo: #Connect to mongodb container
	@docker exec -it $(CONTAINER_MONGODB) $(SHELL)
#-----------------------------------------------------------------------------------------------------------------------


#Command for build and development
.PHONY: npm_build
npm_build: #build js app
	@docker exec -it $(CONTAINER_VUE) npm run build

.PHONY: npm_run
npm_run: #Run development js server
	@docker exec -it $(CONTAINER_VUE) npm run serve

.PHONY: go_build
go_build: #build app go
	@docker exec -it $(CONTAINER_GOLANG) go build -v ./cmd/main.go

.PHONY: go_test
go_test: #run the test app go
	@docker exec -it $(CONTAINER_GOLANG) go test -v -race -timeout 30s ./...

.PHONY: go
go: #run the compiled app go
	@docker exec -it $(CONTAINER_GOLANG) ./main

.PHONY: grpc_go
grpc_go: # build grpc go files
	@docker exec -it $(CONTAINER_GOLANG) sh /var/scripts/proto.sh

.PHONY: grpc_php
grpc_php: #build grpc php files
	@docker exec -it $(CONTAINER_PHP) sh /var/scripts/proto.sh

.PHONY: grpc_build
grpc_build: grpc_go grpc_php
#-----------------------------------------------------------------------------------------------------------------------


#Other command
.PHONY: php_clean
php_clean: #Clean cache and config
	@docker exec -it $(CONTAINER_PHP) php artisan config:cache

.PHONY: php_key
php_key: #generate APP key
	@docker exec -it $(CONTAINER_PHP) php artisan key:generate

.PHONY: own
own: #Set ownership
	@sudo chown $(USER):$(USER) . -R

.PHONY: show
show: #show docker's containers
	@sudo docker ps

.PHONY: site_disable
site_disable: #Site disable
	@if [ -z ${name} ]; then \
		printf 'Name site not exist \nFor example command: "make site_disable name=<name_site>"\n' exit 1; \
 	fi

	@if [ ! -z ${name} ]; then \
		docker exec -t $(CONTAINER_SERVER) mv /etc/nginx/conf.d/${name}.conf /etc/nginx/sites-available/${name}.conf; \
		docker restart $(CONTAINER_SERVER) ; \
	fi

.PHONY: site_enable
site_enable: #Site enable
	@if [ -z ${name} ]; then \
		printf 'Name site not exist \nFor example command: "make site_enable name=<name_site>"\n' exit 1; \
 	fi

	@if [ ! -z ${name} ]; then \
		docker exec -t $(CONTAINER_SERVER) mv /etc/nginx/sites-available/${name}.conf /etc/nginx/conf.d/${name}.conf; \
		docker restart $(CONTAINER_SERVER); \
	fi

.PHONY: dump
dump: #Dump DB
	@echo 'For example command: "make dump name=<name_file_db> db=<demo>"'
	@if [ -z ${name} ]; then \
		echo 'Name file dump not exist' exit 1; \
	fi

	@if [ -z ${db} ]; then \
		echo 'Name DB not exist. Set default name DB $(DB_NAME)'; \
	fi

	@if [ ! -z ${db} ]; then \
		$(DB_NAME) ?= ${db}; \
	fi

	@if [ ! -z ${name} ]; then \
		tar -xvf ./dump/${name}.tar.gz; \
		docker exec -i $(CONTAINER_POSTGRES) psql $(DB_NAME) < ${name}.sql; \
	fi

	@if [ -f ${name}.sql ]; then \
		rm ${name}.sql; \
		echo 'Database dump was successful.'; \
		echo 'Use DB $(DB_NAME)'; \
	fi

#-----------------------------------------------------------------------------------------------------------------------
.PHONY: help
help: #help to command from makefile
	@echo WORK IN CONTAINER \\n\\r \
 	  up: =\> start docker containers @docker-compose up -d \\n\\r \
	  build: =\> build docker container @docker-compose build \\n\\r \
	  down: =\> stop and remove docker containers @docker-compose down \\n\\r \
	  start: =\> start docker containers @docker-compose start \\n\\r \
	  stop: =\> stop docker containers @docker-compose stop \\n\\r \
	  restart: =\> restart docker containers @docker-compose restart \\n\\r

	@echo INSTALL APP \\n\\r \
	  laravel_i: =\> Create new Laravel project. Last version "(container PHP)" \\n\\r \
	  composer_i: =\> Install php dependency "(container PHP)" \\n\\r \
	  vui_i: =\> Create new vue project "(container VUI)" \\n\\r \
	  npm_i: =\> Install js dependency "(container VUI)" \\n\\r

	@echo CONNECT CONTAINER \\n\\r \
	  connect_php: =\> Connect to php container \\n\\r \
	  connect_psql: =\>Connect to DB "(POSTGRES)" container \\n\\r \
	  connect_rmq: =\> Connect to rabbitmq container \\n\\r \
	  connect_server: =\> Connect to server container \\n\\r \
	  connect_go: =\> Connect to golang container \\n\\r \
	  connect_vue: =\> Connect to vue container \\n\\r \
	  connect_mongo: =\> Connect to mongodb container \\n\\r

	@echo BUILD AND DEVELOPMENT \\n\\r \
	  npm_build: =\> Build js app \\n\\r \
	  npm_run: =\> Run development js server \\n\\r \
	  go_build: =\> Build app go \\n\\r \
	  go_test: =\> Run the test app go \\n\\r \
	  go: =\> Run the compiled app go \\n\\r \
	  grpc_go: =\> Build grpc go files \\n\\r \
	  grpc_php: =\> Build grpc php files \\n\\r \
	  grpc_build: =\> Build grpc all files \\n\\r

	@echo HELP COMMAND \\n\\r \
	  php_clean: =\> Clean cache and config \\n\\r \
	  php_key: =\> Generate APP key \\n\\r \
	  own: =\> Set ownership \\n\\r \
	  show: =\> "Show docker's containers" \\n\\r \
	  site_disable "name=<name_site>": =\> Site disable \\n\\r \
	  site_enable "name=<name_site>": =\> Site enable \\n\\r \
	  dump "name=<name_file_db>": =\> Dump DB. Format file db was be example_dump_db.tar.gz \\n\\r

