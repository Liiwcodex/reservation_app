#!/usr/bin/env bash
set -euo pipefail

echo "▶ Building images…"
docker compose build

echo "▶ Starting dbs (detached)…"
docker compose up -d mariadb mongodb

echo "⏳ Waiting 8s for MariaDB…"
sleep 8

# ─────────────────────────────────────────────────────────────────────────────
# Create Laravel skeleton if not present (supports non-empty repo)
# ─────────────────────────────────────────────────────────────────────────────
if [ ! -f "artisan" ]; then
  echo "▶ Creating Laravel app (copying from temp)…"
  docker compose run --rm php bash -lc '
    set -e
    mkdir -p /tmp/laravel && rm -rf /tmp/laravel/*
    composer create-project laravel/laravel /tmp/laravel
    # Copy into the mounted project dir; preserve your existing docker/, scripts/, etc.
    cp -a /tmp/laravel/. /var/www/html/
    rm -rf /tmp/laravel
  '
fi

# ─────────────────────────────────────────────────────────────────────────────
# Frontend toolchain (pnpm/Vite)
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Preparing pnpm/Vite…"
docker compose up -d node
docker compose run --rm node sh -lc "corepack enable && (pnpm -v || npm i -g pnpm)"
docker compose run --rm node sh -lc "pnpm install"

# ─────────────────────────────────────────────────────────────────────────────
# .env setup
# ─────────────────────────────────────────────────────────────────────────────
if [ ! -f ".env" ]; then
  echo "▶ Creating .env…"
  cp .env.example .env
  sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
  sed -i 's/^DB_HOST=.*/DB_HOST=mariadb/' .env
  sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env
  sed -i 's/^DB_DATABASE=.*/DB_DATABASE=reservation/' .env
  sed -i 's/^DB_USERNAME=.*/DB_USERNAME=reservation/' .env
  sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD=reservation/' .env
  sed -i 's|^APP_URL=.*|APP_URL=http://localhost:8080|' .env
  if ! grep -q '^MONGO_URL=' .env; then
    echo "MONGO_URL=mongodb://mongodb:27017/analytics" >> .env
  fi
fi

echo "▶ App key…"
docker compose run --rm php php artisan key:generate

echo "▶ Storage perms & link…"
chmod -R 777 storage bootstrap/cache || true
docker compose run --rm php php artisan storage:link || true

echo "▶ Migrate default tables…"
docker compose run --rm php php artisan migrate --force

echo "▶ Start full stack…"
docker compose up -d

echo "✅ Done. Open http://localhost:8080"
