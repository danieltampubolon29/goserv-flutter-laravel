<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Point extends Model
{
    protected $table = 'points';
    protected $fillable = ['user_id', 'mission_id', 'point','transaksi', 'tanggal'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mission()
    {
        return $this->belongsTo(Mission::class);
    }
}