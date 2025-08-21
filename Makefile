SHELL := /bin/bash

.PHONY: init up down build logs sh-php sh-node composer artisan npm pnpm

init:
	@./scripts/init.sh

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f --tail=200

sh-php:
	docker compose exec php bash

sh-node:
	docker compose exec node sh

composer:
	docker compose run --rm php composer $(cmd)

artisan:
	docker compose run --rm php php artisan $(cmd)

npm:
	docker compose run --rm node npm $(cmd)

pnpm:
	docker compose run --rm node sh -lc "corepack enable && pnpm $(cmd)"
