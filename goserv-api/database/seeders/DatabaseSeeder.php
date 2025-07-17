<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;  // pastikan diimport

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::factory()->create([
            'name' => 'Admin',
            'email' => 'admin@gmail.com',
            'password' => Hash::make('admin'),   // password di-hash
            'role' => 'admin',
        ]);

        User::factory()->create([
            'name' => 'Daniel Fernando Tampubolon',
            'email' => 'daniel@gmail.com',
            'password' => Hash::make('daniel'),   // password di-hash
            'role' => 'customer',
        ]);

        User::factory()->create([
            'name' => 'Derin Fibonacci',
            'email' => 'derin@gmail.com',
            'password' => Hash::make('derin'),
            'role' => 'customer',
        ]);

        User::factory()->create([
            'name' => 'Gatot Hendra Kusumma',
            'email' => 'gatot@gmail.com',
            'password' => Hash::make('gatot'),
            'role' => 'customer',
        ]);

        User::factory()->create([
            'name' => 'Salman Gymnastiar',
            'email' => 'salman@gmail.com',
            'password' => Hash::make('salman'),
            'role' => 'customer',
        ]);
    }
}
