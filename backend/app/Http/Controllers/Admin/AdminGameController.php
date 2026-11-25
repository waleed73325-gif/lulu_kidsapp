<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Models\EducationalGame;
use App\Models\Category;

class AdminGameController extends Controller
{
    public function index(Request $request)
    {
        $query = EducationalGame::with(['category'])->withCount('questions');

        if ($request->filled('game_type')) {
            $query->where('game_type', $request->game_type);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $games = $query->orderBy('sort_order')->orderBy('id', 'desc')->paginate(15);
        $categories = Category::all();

        return view('admin.games.index', compact('games', 'categories'));
    }

    public function create()
    {
        $categories = Category::all();
        $game = new EducationalGame([
            'game_type' => 'letter_matching',
            'primary_color' => '#6C5CE7',
            'stars_reward' => 5,
            'sort_order' => 1,
            'access_level' => 'free',
            'is_published' => true,
            'icon' => 'videogame_asset_rounded',
        ]);

        return view('admin.games.form', compact('game', 'categories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:191',
            'game_type' => 'required|string|in:letter_matching,letter_ordering,general_puzzle',
            'category_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'icon' => 'required|string|max:100',
            'primary_color' => 'required|string|max:20',
            'access_level' => 'required|in:free,premium',
            'stars_reward' => 'required|integer|min:1|max:50',
            'sort_order' => 'required|integer|min:0',
            'is_published' => 'nullable|boolean',
        ]);

        $validated['is_published'] = $request->has('is_published');
        $validated['slug'] = Str::slug($validated['title']) . '-' . Str::random(5);

        $game = EducationalGame::create($validated);

        return redirect()->route('admin.games.questions.index', $game->id)
            ->with('success', 'تم إنشاء اللعبة بنجاح! يمكنك الآن إضافة المراحل والأسئلة الخاصة بها.');
    }

    public function edit(EducationalGame $game)
    {
        $categories = Category::all();
        return view('admin.games.form', compact('game', 'categories'));
    }

    public function update(Request $request, EducationalGame $game)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:191',
            'game_type' => 'required|string|in:letter_matching,letter_ordering,general_puzzle',
            'category_id' => 'nullable|exists:categories,id',
            'description' => 'nullable|string',
            'icon' => 'required|string|max:100',
            'primary_color' => 'required|string|max:20',
            'access_level' => 'required|in:free,premium',
            'stars_reward' => 'required|integer|min:1|max:50',
            'sort_order' => 'required|integer|min:0',
            'is_published' => 'nullable|boolean',
        ]);

        $validated['is_published'] = $request->has('is_published');

        $game->update($validated);

        return redirect()->route('admin.games.index')->with('success', 'تم تحديث بيانات اللعبة التعليمية بنجاح.');
    }

    public function destroy(EducationalGame $game)
    {
        $game->delete();
        return redirect()->route('admin.games.index')->with('success', 'تم حذف اللعبة التعليمية بنجاح.');
    }
}
