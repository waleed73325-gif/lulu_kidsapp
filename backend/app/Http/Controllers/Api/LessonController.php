<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Lesson;

class LessonController extends Controller
{
    /**
     * قائمة الدروس (مع إشارة هل الدرس مجاني أم مدفوع)
     */
    public function index(Request $request)
    {
        $query = Lesson::with('category')->where('is_published', true)->orderBy('sort_order');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $lessons = $query->get()->map(function ($lesson) {
            return [
                'id' => $lesson->id,
                'category_id' => $lesson->category_id,
                'category_slug' => $lesson->category?->slug,
                'title' => $lesson->title,
                'subtitle' => $lesson->subtitle,
                'content_arabic' => $lesson->content_arabic,
                'example_word' => $lesson->example_word,
                'narration_text' => $lesson->narration_text,
                'display_icon' => $lesson->display_icon,
                'primary_color' => $lesson->primary_color,
                'media_type' => $lesson->media_type,
                'media_path' => $lesson->media_path,
                'audio_path' => $lesson->audio_path,
                'audio_url' => $lesson->audio_url,
                'access_level' => $lesson->access_level,
                'is_free' => $lesson->isFree(),
                'stars_reward' => $lesson->stars_reward,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $lessons,
        ]);
    }

    /**
     * تفاصيل الدرس ومحتواه (التحقق الأمني من صلاحية الوصول على الخادم)
     */
    public function show(Request $request, $id)
    {
        $lesson = Lesson::where('is_published', true)->findOrFail($id);

        // إذا كان الدرس مدفوعاً، نتحقق من سريان اشتراك المستخدم
        if (!$lesson->isFree()) {
            $user = $request->user('sanctum');

            if (!$user || !$user->hasActiveSubscription()) {
                return response()->json([
                    'success' => false,
                    'message' => 'هذا الدرس مخصص لمشتركي لولو بلس. يرجى الاشتراك أو تجديد الباقة للوصول.',
                    'requires_subscription' => true,
                ], 403);
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $lesson->id,
                'category_id' => $lesson->category_id,
                'title' => $lesson->title,
                'subtitle' => $lesson->subtitle,
                'content_arabic' => $lesson->content_arabic,
                'example_word' => $lesson->example_word,
                'narration_text' => $lesson->narration_text,
                'display_icon' => $lesson->display_icon,
                'primary_color' => $lesson->primary_color,
                'media_type' => $lesson->media_type,
                'media_path' => $lesson->media_path,
                'audio_path' => $lesson->audio_path,
                'audio_url' => $lesson->audio_url,
                'access_level' => $lesson->access_level,
                'stars_reward' => $lesson->stars_reward,
            ],
        ]);
    }
}
