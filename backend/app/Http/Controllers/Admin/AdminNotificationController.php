<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParentNotification;
use App\Models\User;

class AdminNotificationController extends Controller
{
    /**
     * عرض قائمة الإشعارات والتعميمات المرسلة
     */
    public function index(Request $request)
    {
        $type = $request->get('type', 'all');
        $query = ParentNotification::with('user')->latest();

        if ($type !== 'all') {
            $query->where('type', $type);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('body', 'like', "%{$search}%")
                  ->orWhereHas('user', function ($uq) use ($search) {
                      $uq->where('name', 'like', "%{$search}%")
                         ->orWhere('email', 'like', "%{$search}%");
                  });
            });
        }

        $notifications = $query->paginate(20)->withQueryString();

        $stats = [
            'total' => ParentNotification::count(),
            'unread' => ParentNotification::where('is_read', false)->count(),
            'read' => ParentNotification::where('is_read', true)->count(),
            'broadcast' => ParentNotification::whereIn('type', ['general', 'announcement', 'offer', 'update', 'alert'])->count(),
        ];

        return view('admin.notifications.index', compact('notifications', 'stats', 'type'));
    }

    /**
     * شاشة إنشاء وإرسال إشعار أو تعميم جديد
     */
    public function create(Request $request)
    {
        $parents = User::where('role', 'parent')->select('id', 'name', 'email', 'phone')->get();
        $selectedUserId = $request->get('user_id');

        return view('admin.notifications.create', compact('parents', 'selectedUserId'));
    }

    /**
     * تنفيذ الإرسال الجماعي أو الفردي لأولياء الأمور
     */
    public function send(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:150',
            'body' => 'required|string|max:1000',
            'target' => 'required|in:all,active_subscribers,free_parents,specific_user',
            'user_id' => 'required_if:target,specific_user|nullable|exists:users,id',
            'type' => 'required|string|in:general,announcement,offer,update,alert',
        ]);

        $userIds = [];

        switch ($request->target) {
            case 'all':
                $userIds = User::where('role', 'parent')->pluck('id')->toArray();
                break;
            case 'active_subscribers':
                $userIds = User::where('role', 'parent')
                    ->whereHas('subscriptions', function ($q) {
                        $q->where('status', 'active')->where('ends_at', '>', now());
                    })
                    ->pluck('id')
                    ->toArray();
                break;
            case 'free_parents':
                $userIds = User::where('role', 'parent')
                    ->whereDoesntHave('subscriptions', function ($q) {
                        $q->where('status', 'active')->where('ends_at', '>', now());
                    })
                    ->pluck('id')
                    ->toArray();
                break;
            case 'specific_user':
                $userIds = [$request->user_id];
                break;
        }

        if (empty($userIds)) {
            return back()->withInput()->with('error', 'لم يتم العثور على أي أولياء أمور مسجلين ضمن الفئة المختارة!');
        }

        $now = now();
        $batch = [];
        foreach ($userIds as $userId) {
            $batch[] = [
                'user_id' => $userId,
                'title' => $request->title,
                'body' => $request->body,
                'type' => $request->type,
                'data' => json_encode(['sender' => 'admin', 'sent_at' => $now->toIso8601String()]),
                'is_read' => false,
                'read_at' => null,
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        // إدراج بدُفعات (chunks) للأداء العالي ودعم ملايين السجلات
        foreach (array_chunk($batch, 500) as $chunk) {
            ParentNotification::insert($chunk);
        }

        $count = count($userIds);
        return redirect()->route('admin.notifications.index')
            ->with('success', "تم إرسال الإشعار بنجاح إلى {$count} من أولياء الأمور! 📢✨");
    }

    /**
     * حذف إشعار
     */
    public function destroy($id)
    {
        $notification = ParentNotification::findOrFail($id);
        $notification->delete();

        return back()->with('success', 'تم حذف الإشعار بنجاح.');
    }
}
