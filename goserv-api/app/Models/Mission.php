<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mission extends Model
{
    protected $table = 'missions';
    protected $fillable = [
        'nama',
        'harga',
        'point',
        'tanggal_mulai',
        'tanggal_selesai',
        'status',
    ];
}
