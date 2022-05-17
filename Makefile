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
#-----------------------------------------------------------------------------------------------------------------------


# Work in containers
.PHONY: up
up: #start docker containers @docker-compose up -d
	@docker-compose up -d

.PHONY: build
build: #build docker container @docker-compose build
	@docker-compose build

.PHONY: down
down: #stop docker containers
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


#Commanf for build and development
.PHONY: npm_build
npm_build: #build js app
	@docker exec -it $(CONTAINER_VUE) npm run build

.PHONY: npm_run
npm_run: #Run development js server
	@docker exec -it $(CONTAINER_VUE) npm run serve

.PHONY: go_build
go_build: #build app go
	@docker exec -it ${CONTAINER_GOLANG} go build -v ./cmd/main.go

.PHONY: go_test
go_test: #run the test app go
	@docker exec -it ${CONTAINER_GOLANG} go test -v -race -timeout 30s ./...

.PHONY: go
go: #run the compiled app go
	@docker exec -it ${CONTAINER_GOLANG} ./main
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