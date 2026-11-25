<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminLessonController;
use App\Http\Controllers\Admin\AdminCategoryController;
use App\Http\Controllers\Admin\AdminPaymentController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\Admin\AdminMotivationalSoundController;
use App\Http\Controllers\Admin\AdminGameController;
use App\Http\Controllers\Admin\AdminGameQuestionController;
use App\Http\Controllers\Admin\AdminPlanController;
use App\Http\Controllers\Admin\AdminNotificationController;

/*
|--------------------------------------------------------------------------
| Web Routes - Lulu Kids Platform & Admin Panel
|--------------------------------------------------------------------------
*/

// توجيه الصفحة الرئيسية مباشرة إلى لوحة التحكم
Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});

// المسار الافتراضي لتسجيل الدخول
Route::get('/login', function () {
    return redirect()->route('admin.login');
})->name('login');

// مسارات تسجيل دخول مدير النظام
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('admin.login.post');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');

    // مسارات الإدارة المحمية بوسيط admin
    Route::middleware(['auth', 'admin'])->group(function () {
        Route::get('/', function () {
            return redirect()->route('admin.dashboard');
        });

        Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('admin.dashboard');

        // إدارة الدروس والأنشطة (CRUD كامل)
        Route::resource('lessons', AdminLessonController::class)->names('admin.lessons');

        // إدارة الألعاب التعليمية ومراحلها
        Route::resource('games', AdminGameController::class)->names('admin.games');
        Route::resource('games.questions', AdminGameQuestionController::class)->names('admin.games.questions');

        // إدارة الجزر والتصنيفات
        Route::resource('categories', AdminCategoryController::class)->names('admin.categories')->except(['create', 'show']);

        // إدارة باقات الاشتراك (Lulu+ Plans)
        Route::resource('plans', AdminPlanController::class)->names('admin.plans')->except(['show']);
        Route::post('plans/{plan}/toggle', [AdminPlanController::class, 'toggle'])->name('admin.plans.toggle');

        // مراجعة التحويلات المالية وتفعيل الاشتراكات
        Route::get('/payments', [AdminPaymentController::class, 'index'])->name('admin.payments.index');
        Route::post('/payments/{id}/approve', [AdminPaymentController::class, 'approve'])->name('admin.payments.approve');
        Route::post('/payments/{id}/reject', [AdminPaymentController::class, 'reject'])->name('admin.payments.reject');

        // إدارة أولياء الأمور والأطفال
        Route::get('/users', [AdminUserController::class, 'index'])->name('admin.users.index');

        // مركز الإشعارات والتعميمات
        Route::get('/notifications', [AdminNotificationController::class, 'index'])->name('admin.notifications.index');
        Route::get('/notifications/create', [AdminNotificationController::class, 'create'])->name('admin.notifications.create');
        Route::post('/notifications/send', [AdminNotificationController::class, 'send'])->name('admin.notifications.send');
        Route::delete('/notifications/{id}', [AdminNotificationController::class, 'destroy'])->name('admin.notifications.destroy');

        // إدارة الأصوات التحفيزية ومؤثرات التشجيع
        Route::get('/sounds', [AdminMotivationalSoundController::class, 'index'])->name('admin.sounds.index');
        Route::post('/sounds/{key}', [AdminMotivationalSoundController::class, 'update'])->name('admin.sounds.update');
        Route::delete('/sounds/{key}', [AdminMotivationalSoundController::class, 'destroy'])->name('admin.sounds.destroy');
    });
});

// مسار موثوق لخدمة ملفات التخزين العامة (Storage) على بيئة ويندوز وكافة خوادم التطوير
Route::get('/storage/{path}', function ($path) {
    $filePath = storage_path('app/public/' . $path);
    
    if (file_exists($filePath)) {
        return response()->file($filePath);
    }

    // فحص احتياطي في مسار بيئة الاختبارات في حال وجود إيصالات تجريبية سابقة
    $testFilePath = storage_path('framework/testing/disks/public/' . $path);
    if (file_exists($testFilePath)) {
        return response()->file($testFilePath);
    }

    abort(404, 'الملف المطلوب غير موجود على الخادم');
})->where('path', '.*')->name('storage.file');

