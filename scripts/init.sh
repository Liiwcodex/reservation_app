#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/html"

if [ ! -f "$APP_DIR/artisan" ]; then
  echo "[init] Creating new Laravel app..."
  composer create-project laravel/laravel "$APP_DIR"
fi

cd "$APP_DIR"

# Configure Laravel .env for Docker services
if ! grep -q "DB_HOST=db" .env; then
  echo "[init] Tuning .env for Docker services"
  php -r "
  file_put_contents('.env', preg_replace([
    '/DB_HOST=.*/','/DB_PORT=.*/','/DB_DATABASE=.*/','/DB_USERNAME=.*/','/DB_PASSWORD=.*/',
    '/CACHE_DRIVER=.*/','/QUEUE_CONNECTION=.*/','/SESSION_DRIVER=.*/'
  ], [
    'DB_HOST=db','DB_PORT=3306','DB_DATABASE=reservation','DB_USERNAME=app','DB_PASSWORD=app',
    'CACHE_DRIVER=redis','QUEUE_CONNECTION=redis','SESSION_DRIVER=redis'
  ], file_get_contents('.env')));
  "
fi

# Packages
composer require predis/predis

# App key
php artisan key:generate || true

# Minimal booking scaffold
mkdir -p resources/views/bookings app/Http/Controllers

cat > app/Http/Controllers/BookingController.php <<'PHP'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function index()
    {
        // TODO: fetch properties/availability
        return view('bookings.index');
    }

    public function create(int $propertyId)
    {
        // TODO: fetch property, pricing & availability
        return view('bookings.create', ['propertyId' => $propertyId]);
    }

    public function store(Request $request, int $propertyId)
    {
        // TODO: validate, create booking, redirect
        return redirect('/')->with('status', 'Booking submitted!');
    }
}
PHP

mkdir -p routes
cat > routes/web.php <<'PHP'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BookingController;

Route::get('/', function () { return view('welcome'); });
Route::get('/bookings', [BookingController::class, 'index'])->name('bookings.index');
Route::get('/book/{propertyId}', [BookingController::class, 'create'])->name('bookings.create');
Route::post('/book/{propertyId}', [BookingController::class, 'store'])->name('bookings.store');
PHP

cat > resources/views/bookings/index.blade.php <<'BLADE'
@extends('layouts.app')

@section('content')
<div class="container mx-auto py-8">
  <h1 class="text-2xl font-bold mb-4">Bookings</h1>
  <p>Starter page. Replace with property search + availability results.</p>
</div>
@endsection
BLADE

mkdir -p resources/views/layouts
cat > resources/views/layouts/app.blade.php <<'BLADE'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{ config('app.name', 'ReservationApp') }}</title>
  @vite(['resources/css/app.css','resources/js/app.js'])
</head>
<body>
  <nav style="padding:1rem;background:#111;color:#fff">
    <a href="/" style="color:#fff;margin-right:1rem;">Home</a>
    <a href="{{ route('bookings.index') }}" style="color:#fff;">Bookings</a>
  </nav>
  <main>@yield('content')</main>
</body>
</html>
BLADE

cat > resources/views/bookings/create.blade.php <<'BLADE'
@extends('layouts.app')

@section('content')
<div class="container mx-auto py-8">
  <h1 class="text-2xl font-bold mb-4">Book Property #{{ $propertyId }}</h1>
  <form method="POST" action="{{ route('bookings.store', ['propertyId' => $propertyId]) }}">
    @csrf
    <label>Check-in <input type="date" name="check_in" required></label>
    <label>Check-out <input type="date" name="check_out" required></label>
    <button type="submit">Submit</button>
  </form>
</div>
@endsection
BLADE

# Build frontend assets once (Vite default)
if [ -f package.json ]; then
  npm pkg set name="reservation-app"
fi

echo "[init] Done. You can now run migrations or start coding."
