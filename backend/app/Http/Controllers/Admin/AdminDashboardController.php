<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Child;
use App\Models\Lesson;
use App\Models\Category;
use App\Models\Payment;
use App\Models\Subscription;
use App\Models\Order;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'total_parents' => User::where('role', 'parent')->count(),
            'total_children' => Child::count(),
            'total_lessons' => Lesson::count(),
            'total_categories' => Category::count(),
            'pending_payments' => Payment::where('status', 'pending')->count(),
            'active_subscriptions' => Subscription::where('status', 'active')->where('ends_at', '>', now())->count(),
            'cancelled_subscriptions' => Subscription::where('status', 'revoked')->count(),
            'total_revenue' => Order::where('status', 'verified')->sum('amount'),
        ];

        $recentPendingPayments = Payment::with('order.user', 'order.plan')
            ->where('status', 'pending')
            ->latest()
            ->take(5)
            ->get();

        $recentCancelledSubscriptions = Subscription::with('user', 'order.plan')
            ->where('status', 'revoked')
            ->latest('updated_at')
            ->take(5)
            ->get();

        $recentLessons = Lesson::with('category')
            ->latest()
            ->take(6)
            ->get();

        return view('admin.dashboard', compact('stats', 'recentPendingPayments', 'recentCancelledSubscriptions', 'recentLessons'));
    }
}
