<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\Subscription;
use App\Models\ParentNotification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class AdminPaymentController extends Controller
{
    public function index(Request $request)
    {
        $status = $request->get('status', 'all');
        $query = Payment::with(['order.user', 'order.plan'])->latest();

        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $payments = $query->paginate(15)->withQueryString();
        $counts = [
            'all' => Payment::count(),
            'pending' => Payment::where('status', 'pending')->count(),
            'verified' => Payment::where('status', 'verified')->count(),
            'rejected' => Payment::where('status', 'rejected')->count(),
        ];

        return view('admin.payments.index', compact('payments', 'counts', 'status'));
    }

    /**
     * اعتماد وتفعيل الاشتراك بعد التأكد من وصول الحوالة
     */
    public function approve(Request $request, $id)
    {
        $payment = Payment::with('order.plan', 'order.user')->findOrFail($id);

        if ($payment->status === 'verified') {
            return back()->with('error', 'هذه الحوالة معتمدة ومفعلة مسبقاً!');
        }

        DB::transaction(function () use ($payment) {
            $order = $payment->order;
            $plan = $order->plan;
            $user = $order->user;

            // 1. تحديث حالة الدفع والطلب
            $payment->update([
                'status' => 'verified',
                'reviewed_by' => Auth::id(),
                'reviewed_at' => now(),
            ]);

            $order->update(['status' => 'verified']);

            // 2. تفعيل أو تمديد الاشتراك
            $durationDays = $plan ? $plan->duration_days : 365;
            $currentSub = $user->activeSubscription();
            $startsAt = $currentSub ? $currentSub->ends_at : now();
            $endsAt = (clone $startsAt)->addDays($durationDays);

            Subscription::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'order_id' => $order->id,
                    'starts_at' => $startsAt,
                    'ends_at' => $endsAt,
                    'status' => 'active',
                ]
            );

            // 3. إرسال إشعار فوري لولي الأمر
            $planName = $plan ? $plan->name : 'باقة لولو المميزة';
            ParentNotification::send(
                $user,
                'تم اعتماد اشتراكك بنجاح! 🎉',
                "تهانينا! تم التحقق من الحوالة البنكية واعتماد اشتراكك ({$planName}). جميع الدروس والألعاب والمميزات مفتوحة الآن لطفلك.",
                'subscription_approved',
                [
                    'order_id' => $order->id,
                    'payment_id' => $payment->id,
                ]
            );
        });

        return back()->with('success', 'تم التحقق من الحوالة وتفعيل اشتراك ولي الأمر بنجاح! 🎉');
    }

    /**
     * رفض الحوالة مع توضيح السبب لولي الأمر
     */
    public function reject(Request $request, $id)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:255',
        ]);

        $payment = Payment::with('order')->findOrFail($id);

        DB::transaction(function () use ($payment, $request) {
            $payment->update([
                'status' => 'rejected',
                'reviewed_by' => Auth::id(),
                'reviewed_at' => now(),
                'rejection_reason' => $request->rejection_reason,
            ]);

            $payment->order->update(['status' => 'rejected']);

            // إرسال إشعار فوري لولي الأمر مع ذكر سبب الرفض
            ParentNotification::send(
                $payment->order->user_id,
                'تنبيه حول إثبات التحويل البنكي ⚠️',
                "نعتذر منك، لم تتمكن الإدارة من اعتماد التحويل للطلب #ORD-{$payment->order_id}. السبب: {$request->rejection_reason}. يرجى مراجعة بيانات الحوالة أو إعادة إرسال إشعار صحيح.",
                'subscription_rejected',
                [
                    'order_id' => $payment->order_id,
                    'payment_id' => $payment->id,
                    'rejection_reason' => $request->rejection_reason,
                ]
            );
        });

        return back()->with('success', 'تم تسجيل رفض الحوالة مع حفظ السبب بنجاح.');
    }
}
