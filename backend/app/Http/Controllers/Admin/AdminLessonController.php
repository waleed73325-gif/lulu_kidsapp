<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\Lesson;
use App\Models\Category;

class AdminLessonController extends Controller
{
    public function index(Request $request)
    {
        $query = Lesson::with('category');

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->filled('access_level')) {
            $query->where('access_level', $request->access_level);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('content_arabic', 'like', "%{$search}%")
                  ->orWhere('example_word', 'like', "%{$search}%");
            });
        }

        $lessons = $query->orderBy('sort_order')->paginate(12)->withQueryString();
        $categories = Category::where('is_active', true)->get();

        return view('admin.lessons.index', compact('lessons', 'categories'));
    }

    public function create()
    {
        $categories = Category::where('is_active', true)->get();
        return view('admin.lessons.form', [
            'lesson' => new Lesson([
                'access_level' => 'free',
                'stars_reward' => 3,
                'primary_color' => '#6C5CE7',
                'sort_order' => 1,
                'is_published' => true,
            ]),
            'categories' => $categories,
            'isEdit' => false,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:191',
            'subtitle' => 'nullable|string|max:191',
            'content_arabic' => 'required|string|max:50',
            'example_word' => 'nullable|string|max:100',
            'narration_text' => 'nullable|string',
            'display_icon' => 'nullable|string|max:100',
            'primary_color' => 'required|string|max:20',
            'media_type' => 'required|in:interactive,video,audio',
            'access_level' => 'required|in:free,premium',
            'stars_reward' => 'required|integer|min:1|max:10',
            'sort_order' => 'required|integer|min:0',
            'is_published' => 'boolean',
            'audio_file' => 'nullable|file|mimes:mp3,wav,m4a,aac,ogg,webm|max:15360',
        ]);

        $validated['is_published'] = $request->has('is_published');
        $validated['display_icon'] = $validated['display_icon'] ?? 'auto_awesome_rounded';

        if ($request->hasFile('audio_file')) {
            $path = $request->file('audio_file')->store('audio/lessons', 'public');
            $validated['audio_path'] = $path;
        }

        Lesson::create($validated);

        return redirect()->route('admin.lessons.index')
            ->with('success', 'تمت إضافة الدرس الجديد ومرفقاته بنجاح! 🎉');
    }

    public function edit($id)
    {
        $lesson = Lesson::findOrFail($id);
        $categories = Category::where('is_active', true)->get();

        return view('admin.lessons.form', [
            'lesson' => $lesson,
            'categories' => $categories,
            'isEdit' => true,
        ]);
    }

    public function update(Request $request, $id)
    {
        $lesson = Lesson::findOrFail($id);

        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:191',
            'subtitle' => 'nullable|string|max:191',
            'content_arabic' => 'required|string|max:50',
            'example_word' => 'nullable|string|max:100',
            'narration_text' => 'nullable|string',
            'display_icon' => 'nullable|string|max:100',
            'primary_color' => 'required|string|max:20',
            'media_type' => 'required|in:interactive,video,audio',
            'access_level' => 'required|in:free,premium',
            'stars_reward' => 'required|integer|min:1|max:10',
            'sort_order' => 'required|integer|min:0',
            'is_published' => 'boolean',
            'audio_file' => 'nullable|file|mimes:mp3,wav,m4a,aac,ogg,webm|max:15360',
        ]);

        $validated['is_published'] = $request->has('is_published');

        if ($request->boolean('remove_audio')) {
            if ($lesson->audio_path) {
                Storage::disk('public')->delete($lesson->audio_path);
            }
            $validated['audio_path'] = null;
        } elseif ($request->hasFile('audio_file')) {
            if ($lesson->audio_path) {
                Storage::disk('public')->delete($lesson->audio_path);
            }
            $path = $request->file('audio_file')->store('audio/lessons', 'public');
            $validated['audio_path'] = $path;
        }

        $lesson->update($validated);

        return redirect()->route('admin.lessons.index')
            ->with('success', 'تم تحديث بيانات الدرس والمقطع الصوتي بنجاح! ✅');
    }

    public function destroy($id)
    {
        $lesson = Lesson::findOrFail($id);
        if ($lesson->audio_path) {
            Storage::disk('public')->delete($lesson->audio_path);
        }
        $lesson->delete();

        return redirect()->route('admin.lessons.index')
            ->with('success', 'تم حذف الدرس بنجاح.');
    }
}
