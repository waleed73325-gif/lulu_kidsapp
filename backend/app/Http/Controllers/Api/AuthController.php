<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Models\User;
use App\Models\Child;
use App\Models\Payment;
use App\Models\ParentNotification;

class AuthController extends Controller
{
    /**
     * تسجيل حساب جديد لولي الأمر
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:150',
            'email' => 'required|string|email|max:191|unique:users,email',
            'phone' => 'nullable|string|max:20|unique:users,phone',
            'password' => 'required|string|min:6',
            'child_nickname' => 'nullable|string|max:100',
            'child_birth_year' => 'nullable|integer|min:2015|max:2024',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'] ?? null,
            'password' => Hash::make($validated['password']),
            'role' => 'parent',
            'status' => 'active',
        ]);

        // إنشاء ملف أولي للطفل إن وجد
        if (!empty($validated['child_nickname'])) {
            $user->children()->create([
                'nickname' => $validated['child_nickname'],
                'birth_year' => $validated['child_birth_year'] ?? 2021,
                'avatar_id' => 'rabbit_lulu',
                'stars_count' => 12,
                'completed_lessons' => ['let_1', 'num_1'],
            ]);
        }

        // إشعار ترحيبي فوري لولي الأمر
        ParentNotification::send(
            $user,
            'مرحباً بك في تطبيق لولو للأطفال! 🐰✨',
            'يسعدنا انضمامك إلى مجتمع لولو التعليمي الذكي. نتمنى لبطلك الصغير رحلة ممتعة ومليئة بالتعلم والمرح!',
            'welcome'
        );

        $token = $user->createToken('lulu_parent_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'تم إنشاء حساب ولي الأمر بنجاح',
            'data' => [
                'user' => $user->load('children'),
                'token' => $token,
                'has_active_subscription' => false,
                'unread_notifications_count' => 1,
            ],
        ], 201);
    }

    /**
     * تسجيل الدخول
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)
            ->orWhere('phone', $request->email)
            ->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'بيانات الدخول غير صحيحة، يرجى التأكد من البريد وكلمة المرور',
            ], 401);
        }

        if ($user->status !== 'active') {
            return response()->json([
                'success' => false,
                'message' => 'هذا الحساب غير نشط حالياً، يرجى التواصل مع الدعم',
            ], 403);
        }

        $token = $user->createToken('lulu_parent_token')->plainTextToken;

        $unreadNotificationsCount = \App\Models\ParentNotification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الدخول بنجاح',
            'data' => [
                'user' => $user->load('children'),
                'token' => $token,
                'has_active_subscription' => $user->hasActiveSubscription(),
                'active_subscription' => $user->activeSubscription(),
                'unread_notifications_count' => $unreadNotificationsCount,
            ],
        ]);
    }

    /**
     * بيانات ولي الأمر الحالية
     */
    public function me(Request $request)
    {
        $user = $request->user()->load('children');

        $latestPayment = Payment::whereHas('order', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->with('order.plan')->latest()->first();

        $unreadNotificationsCount = \App\Models\ParentNotification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'has_active_subscription' => $user->hasActiveSubscription(),
                'active_subscription' => $user->activeSubscription(),
                'unread_notifications_count' => $unreadNotificationsCount,
                'latest_payment' => $latestPayment ? [
                    'id' => $latestPayment->id,
                    'order_id' => $latestPayment->order_id,
                    'status' => $latestPayment->status,
                    'rejection_reason' => $latestPayment->rejection_reason,
                    'reviewed_at' => $latestPayment->reviewed_at,
                ] : null,
            ],
        ]);
    }

    /**
     * تسجيل الخروج
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل الخروج بنجاح',
        ]);
    }

    /**
     * تحديث بيانات ولقب الطفل لولي الأمر
     */
    public function updateChild(Request $request)
    {
        $validated = $request->validate([
            'child_id' => 'nullable|integer',
            'nickname' => 'required|string|max:100',
            'birth_year' => 'nullable|integer|min:2010|max:2026',
            'avatar_id' => 'nullable|string|max:50',
        ]);

        $user = $request->user();
        $childId = $validated['child_id'] ?? null;

        if ($childId) {
            $child = $user->children()->findOrFail($childId);
        } else {
            $child = $user->children()->first();
            if (!$child) {
                $child = $user->children()->create([
                    'nickname' => $validated['nickname'],
                    'birth_year' => $validated['birth_year'] ?? 2021,
                    'avatar_id' => $validated['avatar_id'] ?? 'rabbit_lulu',
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'تم إنشاء ملف الطفل وتحديث اسمه بنجاح',
                    'data' => [
                        'child' => $child,
                        'user' => $user->fresh()->load('children'),
                    ],
                ]);
            }
        }

        $updateData = ['nickname' => $validated['nickname']];
        if (isset($validated['birth_year'])) {
            $updateData['birth_year'] = $validated['birth_year'];
        }
        if (isset($validated['avatar_id'])) {
            $updateData['avatar_id'] = $validated['avatar_id'];
        }

        $child->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث لقب الطفل بنجاح في قاعدة البيانات',
            'data' => [
                'child' => $child,
                'user' => $user->fresh()->load('children'),
            ],
        ]);
    }

    /**
     * إضافة ملف طفل جديد لحساب ولي الأمر
     */
    public function addChild(Request $request)
    {
        $validated = $request->validate([
            'nickname' => 'required|string|max:100',
            'birth_year' => 'nullable|integer|min:2010|max:2026',
            'avatar_id' => 'nullable|string|max:50',
        ]);

        $user = $request->user();

        if ($user->children()->count() >= 5) {
            return response()->json([
                'success' => false,
                'message' => 'لقد وصلت للحد الأقصى المسموح به من ملفات الأطفال (5 أطفال).',
            ], 422);
        }

        $child = $user->children()->create([
            'nickname' => $validated['nickname'],
            'birth_year' => $validated['birth_year'] ?? 2021,
            'avatar_id' => $validated['avatar_id'] ?? 'rabbit_lulu',
            'stars_count' => 12,
            'completed_lessons' => ['let_1', 'num_1'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تمت إضافة ملف الطفل بنجاح! 🐰✨',
            'data' => [
                'child' => $child,
                'user' => $user->fresh()->load('children'),
            ],
        ], 201);
    }
}
