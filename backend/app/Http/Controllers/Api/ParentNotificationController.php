<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParentNotification;

class ParentNotificationController extends Controller
{
    /**
     * جلب إشعارات ولي الأمر مع عدد غير المقروء
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $notifications = ParentNotification::where('user_id', $user->id)
            ->latest()
            ->paginate(20);

        $unreadCount = ParentNotification::where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications->items(),
                'unread_count' => $unreadCount,
                'has_more' => $notifications->hasMorePages(),
            ],
        ]);
    }

    /**
     * تحديد إشعار معين كمقروء
     */
    public function markAsRead(Request $request, $id)
    {
        $notification = ParentNotification::where('user_id', $request->user()->id)->findOrFail($id);

        $notification->update([
            'is_read' => true,
            'read_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديد الإشعار كمقروء',
        ]);
    }

    /**
     * تحديد جميع الإشعارات كمقروءة
     */
    public function markAllAsRead(Request $request)
    {
        ParentNotification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديد جميع الإشعارات كمقروءة',
        ]);
    }
}
