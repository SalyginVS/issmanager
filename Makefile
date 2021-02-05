up: docker-up
init: docker-down-clear docker-pull docker-build docker-up issmanager-init
test: issmanager-test

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

issmanager-init: issmanager-composer-install  issmanager-assets-install issmanager-wait-db issmanager-migrations  issmanager-fixtures issmanager-ready

issmanager-clear:
	docker run --rm -v ${PWD}/issmanager:/app --workdir=/app alpine rm -f .ready

issmanager-composer-install:
	docker-compose run --rm issmanager-php-cli composer install

issmanager-assets-install:
	docker-compose run --rm issmanager-node npm rebuild node-sass

issmanager-wait-db:
	until docker-compose exec -T issmanager-postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done

issmanager-migrations:
	docker-compose run --rm issmanager-php-cli php bin/console doctrine:migrations:migrate --no-interaction

issmanager-fixtures:
	docker-compose run --rm issmanager-php-cli php bin/console doctrine:fixtures:load --no-interaction

issmanager-ready:
	docker run --rm -v ${PWD}/issmanager:/app --workdir=/app alpine touch .ready

issmanager-test:
	docker-compose run --rm issmanager-php-cli php bin/phpunit

assets-dev:
	docker-compose run --rm issmanager-node npm run dev

build-production:
	docker build --pull --file=issmanager/docker/production/nginx.docker --tag ${REGISTRY_ADDRESS}/issmanager-nginx:${IMAGE_TAG} issmanager
	docker build --pull --file=issmanager/docker/production/php-fpm.docker --tag ${REGISTRY_ADDRESS}/issmanager-php-fpm:${IMAGE_TAG} issmanager
	docker build --pull --file=issmanager/docker/production/php-cli.docker --tag ${REGISTRY_ADDRESS}/issmanager-php-cli:${IMAGE_TAG} issmanager
	docker build --pull --file=issmanager/docker/production/postgres.docker --tag ${REGISTRY_ADDRESS}/issmanager-postgres:${IMAGE_TAG} issmanager

push-production:
	docker push ${REGISTRY_ADDRESS}/issmanager-nginx:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/issmanager-php-fpm:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/issmanager-php-cli:${IMAGE_TAG}
	docker push ${REGISTRY_ADDRESS}/issmanager-postgres:${IMAGE_TAG}

deploy-production:
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'rm -rf docker-compose.yml .env'
	scp -o StrictHostKeyChecking=no -P ${PRODUCTION_PORT} docker-compose-production.yml ${PRODUCTION_HOST}:docker-compose.yml
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "REGISTRY_ADDRESS=${REGISTRY_ADDRESS}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "IMAGE_TAG=${IMAGE_TAG}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "issmanager_APP_SECRET=${issmanager_APP_SECRET}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'echo "issmanager_DB_PASSWORD=${issmanager_DB_PASSWORD}" >> .env'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose pull'
	ssh -o StrictHostKeyChecking=no ${PRODUCTION_HOST} -p ${PRODUCTION_PORT} 'docker-compose --build -d'