<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $fillable = [
        'customer_name',
        'tanggal',
        'jenis_kendaraan',
        'nomor_polisi',
        'service_items',
        'harga',
        'point',
    ];

    protected $casts = [
        'service_items' => 'array', // otomatis decode/encode json
    ];
}
