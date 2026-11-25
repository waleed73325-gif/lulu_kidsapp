<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\LessonController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\ProgressController;
use App\Http\Controllers\Api\ParentNotificationController;
use App\Http\Controllers\Api\MotivationalSoundController;
use App\Http\Controllers\Api\EducationalGameController;

/*
|--------------------------------------------------------------------------
| API Routes (v1) - Lulu Kids Platform
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // المسارات العامة (Public Endpoints)
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/lessons', [LessonController::class, 'index']);
    Route::get('/lessons/{id}', [LessonController::class, 'show']);
    Route::get('/games', [EducationalGameController::class, 'index']);
    Route::get('/games/{id}', [EducationalGameController::class, 'show']);
    Route::post('/games/{id}/complete', [EducationalGameController::class, 'complete']);
    Route::get('/motivational-sounds', [MotivationalSoundController::class, 'index']);
    Route::get('/plans', [SubscriptionController::class, 'plans']);

    // المسارات المحمية لولي الأمر (Protected Parent Routes via Sanctum)
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::post('/children/update', [AuthController::class, 'updateChild']);
        Route::post('/children/add', [AuthController::class, 'addChild']);

        Route::post('/orders', [SubscriptionController::class, 'createOrder']);
        Route::post('/orders/{id}/payments', [SubscriptionController::class, 'submitManualPayment']);
        Route::get('/subscription/status', [SubscriptionController::class, 'status']);
        Route::post('/subscription/sandbox-activate', [SubscriptionController::class, 'sandboxActivate']);
        Route::post('/subscription/cancel', [SubscriptionController::class, 'cancel']);

        Route::get('/progress', [ProgressController::class, 'show']);
        Route::post('/progress/sync', [ProgressController::class, 'sync']);

        // إشعارات وتنبيهات ولي الأمر
        Route::get('/notifications', [ParentNotificationController::class, 'index']);
        Route::post('/notifications/{id}/read', [ParentNotificationController::class, 'markAsRead']);
        Route::post('/notifications/read-all', [ParentNotificationController::class, 'markAllAsRead']);
    });
});
