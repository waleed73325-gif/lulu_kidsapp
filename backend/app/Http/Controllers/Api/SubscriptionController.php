<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Plan;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Subscription;
use App\Models\ParentNotification;

class SubscriptionController extends Controller
{
    /**
     * باقات الاشتراك المتاحة
     */
    public function plans()
    {
        $plans = Plan::where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'data' => $plans,
        ]);
    }

    /**
     * إنشاء طلب اشتراك جديد
     */
    public function createOrder(Request $request)
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:plans,id',
        ]);

        $plan = Plan::findOrFail($validated['plan_id']);
        $user = $request->user();

        $order = Order::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'amount' => $plan->price,
            'currency' => $plan->currency,
            'status' => 'pending',
        ]);

        // إنشاء سجل الدفع المبدئي مباشرة لضمان ظهوره في لوحة تحكم الإدارة
        Payment::firstOrCreate(
            ['order_id' => $order->id],
            [
                'method' => 'bank_transfer',
                'status' => 'pending',
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'تم إنشاء طلب الاشتراك بنجاح، بانتظار إثبات التحويل',
            'data' => [
                'id' => $order->id,
                'order' => $order->load('plan'),
                'bank_details' => [
                    'bank_name' => 'مصرف الراجحي / بنك الرياض',
                    'account_name' => 'مؤسسة لولو للتعليم الذكي',
                    'iban' => 'SA44 8000 0000 1234 5678 9000',
                ],
            ],
        ], 201);
    }

    /**
     * إرسال مرجع التحويل أو إثبات الدفع
     */
    public function submitManualPayment(Request $request, $orderId)
    {
        $validated = $request->validate([
            'transfer_reference' => 'nullable|string|max:191',
            'proof' => 'nullable|image|max:4096', // 4MB max
        ]);

        $order = Order::where('user_id', $request->user()->id)->findOrFail($orderId);

        $paymentData = [
            'method' => 'bank_transfer',
            'transfer_reference' => $validated['transfer_reference'] ?? null,
            'status' => 'pending',
        ];

        if ($request->hasFile('proof')) {
            $paymentData['proof_path'] = $request->file('proof')->store('payment_proofs', 'public');
        }

        $payment = Payment::updateOrCreate(
            ['order_id' => $order->id],
            $paymentData
        );

        // إشعار فوري لولي الأمر بتأكيد استلام الطلب
        ParentNotification::send(
            $request->user(),
            'تم استلام إشعار التحويل ⏳',
            "تم استلام إشعار التحويل البنكي الخاص بالطلب #ORD-{$order->id} بنجاح، وهو قيد المراجعة والتدقيق من قبل الإدارة.",
            'payment_pending',
            [
                'order_id' => $order->id,
                'transfer_reference' => $payment->transfer_reference,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'تم استلام إثبات الدفع بنجاح وهو قيد المراجعة والتحقق',
            'data' => [
                'order_id' => $order->id,
                'payment_status' => $payment->status,
            ],
        ]);
    }

    /**
     * الاستعلام عن حالة الاشتراك الفعال والطلبات المعلقة والتحويلات المرفوضة مع السبب
     */
    public function status(Request $request)
    {
        $user = $request->user();

        // إيجاد آخر عملية دفع خاصة بولي الأمر
        $latestPayment = Payment::whereHas('order', function ($q) use ($user) {
            $q->where('user_id', $user->id);
        })->with('order.plan')->latest()->first();

        $activeSub = $user->activeSubscription();

        $unreadCount = \App\Models\ParentNotification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'has_active_subscription' => $user->hasActiveSubscription(),
                'active_subscription' => $activeSub,
                'unread_notifications_count' => $unreadCount,
                'latest_payment' => $latestPayment ? [
                    'id' => $latestPayment->id,
                    'order_id' => $latestPayment->order_id,
                    'status' => $latestPayment->status,
                    'method' => $latestPayment->method,
                    'transfer_reference' => $latestPayment->transfer_reference,
                    'rejection_reason' => $latestPayment->rejection_reason,
                    'reviewed_at' => $latestPayment->reviewed_at,
                    'plan_name' => $latestPayment->order->plan->name ?? null,
                    'amount' => $latestPayment->order->amount ?? null,
                    'currency' => $latestPayment->order->currency ?? null,
                    'created_at' => $latestPayment->created_at,
                ] : null,
            ],
        ]);
    }

    /**
     * تفعيل تجريبي سريع لبيئة الاختبار والتطوير (Sandbox Mock Activation)
     */
    public function sandboxActivate(Request $request)
    {
        $user = $request->user();

        $sub = Subscription::updateOrCreate(
            [
                'user_id' => $user->id,
            ],
            [
                'starts_at' => now(),
                'ends_at' => now()->addYear(),
                'status' => 'active',
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'تم تفعيل باقة لولو التجريبية لمدة سنة بنجاح (وضع الاختبار)',
            'data' => $sub,
        ]);
    }

    /**
     * إلغاء اشتراك ولي الأمر بشكل نهائي ومؤكد
     */
    public function cancel(Request $request)
    {
        $user = $request->user();

        // جلب كافة الاشتراكات النشطة لولي الأمر
        $activeSubscriptions = $user->subscriptions()
            ->where('status', 'active')
            ->where('ends_at', '>', now())
            ->get();

        if ($activeSubscriptions->isEmpty()) {
            return response()->json([
                'success' => true,
                'message' => 'لا يوجد اشتراك نشط حالياً، الحساب في الوضع المجاني بالفعل.',
                'data' => [
                    'has_active_subscription' => false,
                    'active_subscription' => null,
                ],
            ]);
        }

        // إلغاء وتحديث حالة الاشتراكات فورياً إلى revoked وتوثيق أن الإلغاء تم من قِبل ولي الأمر
        foreach ($activeSubscriptions as $subscription) {
            $subscription->update([
                'status' => 'revoked',
                'ends_at' => now(),
                'cancelled_by' => 'parent',
                'cancelled_at' => now(),
                'cancellation_reason' => 'تم إلغاء الاشتراك من قبل ولي الأمر عبر تطبيق لولو للأطفال',
            ]);
        }

        // إرسال إشعار فوري وتأكيدي لولي الأمر
        ParentNotification::send(
            $user,
            'تم إلغاء الاشتراك ⚠️',
            'تم إلغاء اشتراكك في باقة لولو بنجاح بناءً على طلبك. لا يمكن التراجع عن هذا الإجراء، ويمكنك الاشتراك مجدداً في أي وقت للاستمتاع بكافة الميزات.',
            'subscription_cancelled',
            [
                'cancelled_at' => now()->toIso8601String(),
            ]
        );

        $unreadCount = ParentNotification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'message' => 'تم إلغاء الاشتراك بنجاح. لا يمكن التراجع عن هذا الإجراء.',
            'data' => [
                'has_active_subscription' => false,
                'active_subscription' => null,
                'unread_notifications_count' => $unreadCount,
            ],
        ]);
    }
}
