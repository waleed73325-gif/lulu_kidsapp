<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\EducationalGame;

class EducationalGameController extends Controller
{
    public function index(Request $request)
    {
        $query = EducationalGame::where('is_published', true)
            ->with(['category:id,name_ar,slug,icon'])
            ->withCount('activeQuestions');

        if ($request->filled('game_type')) {
            $query->where('game_type', $request->game_type);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $games = $query->orderBy('sort_order')->orderBy('id', 'asc')->get();

        return response()->json([
            'success' => true,
            'count' => $games->count(),
            'data' => $games,
        ]);
    }

    public function show($id)
    {
        $game = EducationalGame::where('is_published', true)
            ->where(function ($query) use ($id) {
                $query->where('id', $id)->orWhere('slug', $id);
            })
            ->with([
                'category:id,name_ar,slug,icon',
                'activeQuestions' => function ($query) {
                    $query->orderBy('question_order');
                }
            ])
            ->first();

        if (!$game) {
            return response()->json([
                'success' => false,
                'message' => 'اللعبة المطلوبة غير متوفرة أو تم إلغاء نشرها.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $game,
        ]);
    }

    public function complete(Request $request, $id)
    {
        $game = EducationalGame::find($id);
        if (!$game) {
            return response()->json(['success' => false, 'message' => 'اللعبة غير موجودة'], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'أحسنت يا بطل! تم إنهاء مراحل اللعبة بنجاح.',
            'stars_earned' => $game->stars_reward,
        ]);
    }
}
