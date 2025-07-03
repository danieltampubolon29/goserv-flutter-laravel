<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Service extends Model
{
    use HasFactory;

    protected $table = 'services';

    protected $fillable = [
        'customer_name',
        'tanggal',
        'jenis_kendaraan',
        'nomor_polisi',
        'service_items',
        'harga',
    ];

    protected $casts = [
        'service_items' => 'array', 
        'tanggal' => 'date',
    ];
}
