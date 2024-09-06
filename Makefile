include .env


# Install app
.PHONY: laravel_i
laravel_i: #Create new Laravel project. Last version
	@docker exec -it $(PHP_CONTAINER) composer create-project --prefer-dist laravel/laravel .

.PHONY: chat_i
chat_i: #Create new chat project. Last version
	@docker exec -it $(CHAT_CONTAINER) composer create-project spiral/app .

.PHONY: vue_i
vue_i: #Create new vue js project
	@docker exec -it $(NODE_CONTAINER) npm init vuetify

.PHONY: npm_i
npm_i: #Install js dependency
	@docker exec -it $(NODE_CONTAINER) npm install

.PHONY: composer_i
composer_i: #Install php dependency
	@docker exec -it $(PHP_CONTAINER) composer install

.PHONY: composer_du
composer_du: # Composer dump autoload
	@docker exec -it $(PHP_CONTAINER) compose du
#-----------------------------------------------------------------------------------------------------------------------


# Work in containers
.PHONY: up
up: #start docker containers @docker compose up -d
	@docker compose up -d

.PHONY: build
build: #build docker container @docker compose build
	@docker compose build

.PHONY: down
down: #stop and remove docker containers @docker compose down
	@docker compose down

.PHONY: start
start: #start docker containers @docker compose start
	@docker compose start

.PHONY: stop
stop: #stop docker containers @docker compose stop
	@docker compose stop

.PHONY: restart
restart: #restart docker containers @docker compose restart
	@docker compose restart
#-----------------------------------------------------------------------------------------------------------------------


#Connect container
.PHONY: connect_php
connect_php: #Connect to php container
	@docker exec -it $(PHP_CONTAINER) $(SHELL)

.PHONY: connect_psql
connect_psql: #Connect to DB container
	@docker exec -it $(POSTGRES_CONTAINER) $(SHELL)

.PHONY: connect_rmq
connect_rmq: #Connect to rabbitmq container
	@docker exec -it $(RMQ_CONTAINER) $(SHELL)

.PHONY: connect_server
connect_server: #Connect to server container
	@docker exec -it $(NGINX_CONTAINER) $(SHELL)

.PHONY: connect_go
connect_go: #Connect to golang container
	@docker exec -it $(GOLANG_CONTAINER) $(SHELL)

.PHONY: connect_node
connect_node: #Connect to node container
	@docker exec -it $(NODE_CONTAINER) $(SHELL)

.PHONY: connect_mongo
connect_mongo: #Connect to mongodb container
	@docker exec -it $(MONGODB_CONTAINER) $(SHELL)

.PHONY: connect_chat
connect_chat: #Connect to chat container
	@docker exec -it $(CHAT_CONTAINER) $(SHELL)
#-----------------------------------------------------------------------------------------------------------------------


#Command for build and development
.PHONY: npm_build
npm_build: #build js app
	@docker exec -it $(NODE_CONTAINER) npm run build

.PHONY: npm_dev
npm_dev: #Run development js server
	@docker exec -it $(NODE_CONTAINER) npm run dev

.PHONY: go_build
go_build: #build app go
	@docker exec -i $(GOLANG_CONTAINER) go build -o ./bin/sso ./cmd/sso/main.go

.PHONY: go_test
go_test: #run the tests app go
	@docker exec -it $(GOLANG_CONTAINER) go test -v -race -timeout 30s ./...

.PHONY: go
go: #run the compiled app go
	@docker exec -it $(GOLANG_CONTAINER) ./bin/sso

.PHONY: go_dev
go_dev: #run dev app go
	@docker exec -i $(GOLANG_CONTAINER) go run ./cmd/sso/main.go

.PHONY: grpc_go
grpc_go: # build grpc-server go files
	@docker exec -it $(GOLANG_CONTAINER) sh /var/scripts/proto.sh

.PHONY: grpc_php
grpc_php: #build grpc-server php files
	@docker exec -it $(PHP_CONTAINER) sh /var/scripts/proto.sh

.PHONY: grpc_build
grpc_build: grpc_go grpc_php
#-----------------------------------------------------------------------------------------------------------------------


#Other command
.PHONY: php_clean
php_clean: #Clean cache and config
	@docker exec -it $(PHP_CONTAINER) php artisan config:cache

.PHONY: php_key
php_key: #generate APP key
	@docker exec -it $(PHP_CONTAINER) php artisan key:generate

.PHONY: own
own: #Set ownership
	@sudo chown $(USER):$(USER) . -R

.PHONY: show
show: #show docker's containers
	@sudo docker ps

.PHONY: elastic_token
elastic_token: #Generate elastic token
	@docker exec -it $(ELASTICSEARCH_CONTAINER) bin/elasticsearch-create-enrollment-token --scope kibana

.PHONY: kibana_code
kibana_code: #Generate elastic token
	@docker exec -it $(KIBANA_CONTAINER) bin/kibana-verification-code


.PHONY: site_disable
site_disable: #Site disable
	@if [ -z ${name} ]; then \
		printf 'Name site not exist \nFor example command: "make site_disable name=<name_site>"\n' exit 1; \
 	fi

	@if [ ! -z ${name} ]; then \
		docker exec -t $(NGINX_CONTAINER) mv /etc/nginx/conf.d/${name}.conf /etc/nginx/sites-available/${name}.conf; \
		docker restart $(NGINX_CONTAINER) ; \
	fi

.PHONY: site_enable
site_enable: #Site enable
	@if [ -z ${name} ]; then \
		printf 'Name site not exist \nFor example command: "make site_enable name=<name_site>"\n' exit 1; \
 	fi

	@if [ ! -z ${name} ]; then \
		docker exec -t $(NGINX_CONTAINER) mv /etc/nginx/sites-available/${name}.conf /etc/nginx/conf.d/${name}.conf; \
		docker restart $(NGINX_CONTAINER); \
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
		docker exec -i $(POSTGRES_CONTAINER) psql $(DB_NAME) < ${name}.sql; \
	fi

	@if [ -f ${name}.sql ]; then \
		rm ${name}.sql; \
		echo 'Database dump was successful.'; \
		echo 'Use DB $(DB_NAME)'; \
	fi

#-----------------------------------------------------------------------------------------------------------------------

#Helper
.PHONY: help
help: #help to command from makefile
	@echo WORK IN CONTAINER \\n\\r \
 	  up: =\> start docker containers @docker compose up -d \\n\\r \
	  build: =\> build docker container @docker compose build \\n\\r \
	  down: =\> stop and remove docker containers @docker compose down \\n\\r \
	  start: =\> start docker containers @docker compose start \\n\\r \
	  stop: =\> stop docker containers @docker compose stop \\n\\r \
	  restart: =\> restart docker containers @docker compose restart \\n\\r

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
	  connect_node: =\> Connect to node container \\n\\r \
	  connect_mongo: =\> Connect to mongodb container \\n\\r \
	  connect_chat: =\> Connect to chat container \\n\\r

	@echo BUILD AND DEVELOPMENT \\n\\r \
	  npm_build: =\> Build js app \\n\\r \
	  npm_dev: =\> Run development js server \\n\\r \
	  go_build: =\> Build app go \\n\\r \
	  go_dev: =\> Run dev app go \\n\\r \
	  go_test: =\> Run the tests app go \\n\\r \
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

