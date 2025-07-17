<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Request;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\MissionController;
use App\Http\Controllers\Api\ServiceController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::get('/services/history', [ServiceController::class, 'userHistory']);
    Route::post('/logout', [AuthController::class, 'logout']);
});

Route::get('/services/history/{userId}', [ServiceController::class, 'userHistoryById']);

Route::apiResource('services', ServiceController::class);
Route::get('/customers/search', [ServiceController::class, 'searchCustomers']);
Route::get('/users/{userId}/points', [ServiceController::class, 'getUserPoints']); // New route

Route::post('/missions/claim', [MissionController::class, 'claimMission']);
Route::get('missions/user/progress/{user_id}', [MissionController::class, 'userMissionProgress']);
Route::get('missions/active', [MissionController::class, 'active']);
Route::apiResource('missions', MissionController::class);