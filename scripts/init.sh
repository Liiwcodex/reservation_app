#!/usr/bin/env bash
set -euo pipefail

echo "▶ Building images…"
docker compose build

echo "▶ Starting dbs (detached)…"
docker compose up -d mariadb mongodb

# Wait for MariaDB to accept connections (simple sleep is fine for dev)
echo "⏳ Waiting 8s for MariaDB…"
sleep 8

# Create Laravel skeleton if not present
if [ ! -f "artisan" ]; then
  echo "▶ Creating Laravel app…"
  docker compose run --rm php composer create-project laravel/laravel . 
fi

# Ensure Node toolchain
echo "▶ Preparing pnpm/Vite…"
docker compose up -d node
docker compose run --rm node sh -lc "corepack enable && pnpm -v || (npm i -g pnpm && pnpm -v)"
docker compose run --rm node sh -lc "pnpm install"

# .env
if [ ! -f ".env" ]; then
  echo "▶ Creating .env…"
  cp .env.example .env
  # DB
  sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
  sed -i 's/^DB_HOST=.*/DB_HOST=mariadb/' .env
  sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env
  sed -i 's/^DB_DATABASE=.*/DB_DATABASE=reservation/' .env
  sed -i 's/^DB_USERNAME=.*/DB_USERNAME=reservation/' .env
  sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD=reservation/' .env
  # APP URL
  sed -i 's|^APP_URL=.*|APP_URL=http://localhost:8080|' .env
  # Queue/cache to database for simplicity local
  sed -i 's/^CACHE_STORE=.*/CACHE_STORE=file/' .env || true
  sed -i 's/^QUEUE_CONNECTION=.*/QUEUE_CONNECTION=database/' .env || true
  # Mongo (for later analytics)
  if ! grep -q '^MONGO_URL=' .env; then
    echo "MONGO_URL=mongodb://mongodb:27017/analytics" >> .env
  fi
fi

echo "▶ App key…"
docker compose run --rm php php artisan key:generate

echo "▶ Storage perms…"
chmod -R 777 storage bootstrap/cache || true

echo "▶ Migrate default tables…"
docker compose run --rm php php artisan migrate

echo "▶ Start full stack…"
docker compose up -d

echo "✅ Done. Open http://localhost:8080"
