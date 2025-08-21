<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Resource extends Model
{
    protected $fillable = [ 'name','description','capacity','is_active'];

    public function slots(): HasMany{
        return $this->hasMany(Slot::class);
    }

    public function reservation(): HasMany{
        return $this->hasMany(Reservation::class);
    }
}