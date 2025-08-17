# Reservation App — Docker Starter (Laravel + Nginx + MariaDB)

This is a ready-to-clone starter. It bootstraps a **Laravel** app inside Docker and drops in a minimal booking scaffold (routes, controller, views).

## Prerequisites
- Docker + Docker Compose
- Make (optional, but all commands below use it)
- pnpm or npm is optional (Laravel's Vite is set up by default)

## Quick start

```bash
# 1) Unzip and cd into the folder
unzip reservation-app-starter.zip && cd reservation-app-starter

# 2) Copy env file for Docker services (not Laravel's .env)
cp .env.example .env

# 3) Build and initialize the project (creates Laravel in ./src)
make init

# 4) Bring everything up
make up

# 5) Open the app
open http://localhost:8080   # macOS
# or
xdg-open http://localhost:8080  # Linux
```

The initializer will:
- `composer create-project laravel/laravel ./src`
- Configure `src/.env` to talk to MariaDB (db), Redis, Mailhog
- Add a basic BookingController + routes + starter views

### Common tasks

```bash
# Migrations (after you add migrations)
make migrate

# Logs
make logs

# Stop
make down
```

### Project layout

```
.
├─ docker-compose.yml
├─ docker/
│  ├─ php/Dockerfile
│  └─ nginx/default.conf
├─ scripts/
│  └─ init.sh
├─ src/                 # will be created by 'make init' (Laravel codebase)
├─ .env.example         # host-level env used by docker-compose
├─ .env                 # copy of .env.example (you create this)
├─ Makefile
└─ README.md
```

> Note: On first run, Composer will download Laravel into `./src`. This keeps the starter lightweight and lets you regenerate the framework cleanly.
