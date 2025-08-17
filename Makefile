SHELL := /bin/bash

COMPOSE := ./scripts/compose.sh

init: ## Create Laravel app & seed starter code
	$(COMPOSE) up -d db redis
	$(COMPOSE) build app web
	$(COMPOSE) run --rm app bash -lc "chmod +x /scripts/init.sh && /scripts/init.sh"

up: ## Start all services
	$(COMPOSE) up -d

down: ## Stop services
	$(COMPOSE) down

logs: ## Tail app logs
	$(COMPOSE) logs -f app web

migrate: ## Run DB migrations (inside container)
	$(COMPOSE) exec app php artisan migrate --seed

tinker: ## Open Laravel tinker
	$(COMPOSE) exec app php artisan tinker

test: ## Run tests
	$(COMPOSE) exec app php artisan test

.PHONY: init up down logs migrate tinker test
