<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Reservation extends Model
{
    protected $fillable = ['user_id', 'ressource_id', 'slot_id', 'status', 'booked_at'];
    protected $casts = [ "booked_at" => "datetime"];

    public function user(): BelongsTo { return $this-> belongsTo(User::class);}
    public function resource(): BelongsTo { return $this->belongsTo(Resource::class); }
    public function slot(): BelongsTo { return $this->belongsTo(Slot::class); }


}
