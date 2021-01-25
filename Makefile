up: docker-up
init: docker-down-clear docker-pull docker-build docker-up issmanager-init

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

issmanager-init: issmanager-composer-install

issmanager-composer-install:
	docker-compose run --rm issmanager-php-cli composer install

cli:
	docker-compose run --rm issmanager-php-cli php bin/app.php

build-production:
	docker build --pull --file=issmanager/docker/production/nginx.docker --tag ${REGISTRY_ADDRESS}/issmanager-nginx:${IMAGE_TAG} issmanager
	docker build --pull --file=issmanager/docker/production/php-fpm.docker --tag ${REGISTRY_ADDRESS}/issmanager-php-fpm:${IMAGE_TAG} issmanager
	docker build --pull --file=issmanager/docker/production/php-cli.docker --tag ${REGISTRY_ADDRESS}/issmanager-php-cli:${IMAGE_TAG} issmanager

push-production:
	docker push ${REGISTRY_ADDRESS}/issmanager-nginx:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/issmanager-php-fpm:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/issmanager-php-cli:${IMAGE_TAG}

deploy-production:
	ssh ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'rm -rf docker-compose.yml .env'
	scp -P ${PRODUCTION_PORT} docker-compose-production.yml ${PRODUCTION_HOST}:docker-compose.yml
	ssh ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "REGISTRY_ADDRESS=${REGISTRY_ADDRESS}" >> .env'
	ssh ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "IMAGE_TAG=${IMAGE_TAG}" >> .env'
	ssh ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose pull'
	ssh ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose --build -d'