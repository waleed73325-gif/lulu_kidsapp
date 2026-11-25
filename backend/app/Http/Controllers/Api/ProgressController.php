<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Child;
use App\Models\Lesson;
use App\Models\LessonProgress;

class ProgressController extends Controller
{
    /**
     * جلب تقدم الطفل الحالي ورصيد النجوم والدروس المكتملة
     */
    public function show(Request $request)
    {
        $user = $request->user();
        $childId = $request->query('child_id');
        $child = null;
        if ($childId) {
            $child = Child::where('parent_user_id', $user->id)->find($childId);
        }
        if (!$child) {
            $child = Child::where('parent_user_id', $user->id)->first();
        }

        if (!$child) {
            $child = Child::create([
                'parent_user_id' => $user->id,
                'nickname' => 'البطل الصغير',
                'birth_year' => 2021,
                'avatar_id' => 'rabbit_lulu',
                'stars_count' => 12,
                'completed_lessons' => ['let_1', 'num_1'],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'child_id' => $child->id,
                'nickname' => $child->nickname,
                'stars_count' => (int) ($child->stars_count ?? 12),
                'completed_lessons' => $child->completed_lessons ?? ['let_1', 'num_1'],
            ],
        ]);
    }

    /**
     * مزامنة تقدم الطفل والنجوم المكتسبة والدروس المكتملة دون اتصال
     */
    public function sync(Request $request)
    {
        $validated = $request->validate([
            'child_id' => 'nullable|integer',
            'stars_count' => 'nullable|integer|min:0',
            'completed_lessons' => 'nullable|array',
            'completed_lessons.*' => 'string',
            'progress' => 'nullable|array',
            'progress.*.lesson_id' => 'required_with:progress|integer',
            'progress.*.is_completed' => 'required_with:progress|boolean',
            'progress.*.stars_earned' => 'required_with:progress|integer|min:0|max:10',
        ]);

        $user = $request->user();
        $childId = $validated['child_id'] ?? null;
        $child = null;
        if ($childId) {
            $child = Child::where('parent_user_id', $user->id)->find($childId);
        }
        if (!$child) {
            $child = Child::where('parent_user_id', $user->id)->first();
        }

        if (!$child) {
            $child = Child::create([
                'parent_user_id' => $user->id,
                'nickname' => 'البطل الصغير',
                'birth_year' => 2021,
                'avatar_id' => 'rabbit_lulu',
                'stars_count' => 12,
                'completed_lessons' => ['let_1', 'num_1'],
            ]);
        }

        // 1. تحديث عدد النجوم (مع الاحتفاظ بالقيمة الأعلى لضمان عدم ضياع نجوم جمعها الطفل)
        if (isset($validated['stars_count'])) {
            $incomingStars = (int) $validated['stars_count'];
            $currentStars = (int) ($child->stars_count ?? 12);
            $child->stars_count = max($currentStars, $incomingStars);
        }

        // 2. تحديث قائمة الدروس المكتملة (دمج دون تكرار)
        if (!empty($validated['completed_lessons']) && is_array($validated['completed_lessons'])) {
            $currentCompleted = $child->completed_lessons ?? ['let_1', 'num_1'];
            if (!is_array($currentCompleted)) {
                $currentCompleted = ['let_1', 'num_1'];
            }
            $child->completed_lessons = array_values(array_unique(array_merge($currentCompleted, $validated['completed_lessons'])));
        }

        // 3. مزامنة تفاصيل تقدم الدروس الفردية إن وجدت
        if (!empty($validated['progress']) && is_array($validated['progress'])) {
            foreach ($validated['progress'] as $item) {
                $lessonExists = Lesson::where('id', $item['lesson_id'])->exists();
                if ($lessonExists) {
                    LessonProgress::updateOrCreate(
                        [
                            'child_id' => $child->id,
                            'lesson_id' => $item['lesson_id'],
                        ],
                        [
                            'is_completed' => (bool) $item['is_completed'],
                            'stars_earned' => (int) $item['stars_earned'],
                            'completed_at' => !empty($item['is_completed']) ? now() : null,
                        ]
                    );
                }
            }
        }

        $child->save();

        return response()->json([
            'success' => true,
            'message' => 'تمت مزامنة تقدم الطفل بنجاح',
            'data' => [
                'child_id' => $child->id,
                'nickname' => $child->nickname,
                'stars_count' => (int) ($child->stars_count ?? 12),
                'completed_lessons' => $child->completed_lessons ?? ['let_1', 'num_1'],
            ],
        ]);
    }
}
