<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Slot extends Model{
    protected $fillable = [ 'resource_id', 'starts_at', 'ends_at','is_bookable'];
    protected $casts = [
        'starts_at'=> 'datetime',
        'ends_at'=> 'datetime',
        'is_bookable'=> 'boolean',
    ];

    public function resource(): BelongsTo{
        return $this->belongsTo(Resource::class);
    }
    public function reservations(): HasMany{
        return $this->hasMany(Reservation::class);
    }
}