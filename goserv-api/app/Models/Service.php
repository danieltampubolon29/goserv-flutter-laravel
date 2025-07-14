<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Service extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'customer_name',
        'tanggal',
        'jenis_kendaraan',
        'nomor_polisi',
        'service_items',
        'harga',
        'point'
    ];

    protected $casts = [
        'service_items' => 'array'
    ];

    // Tambah relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}