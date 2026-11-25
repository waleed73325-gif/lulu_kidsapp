<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\MotivationalSound;

class AdminMotivationalSoundController extends Controller
{
    public function index()
    {
        $sounds = MotivationalSound::orderBy('id')->get();
        return view('admin.sounds.index', compact('sounds'));
    }

    public function update(Request $request, $key)
    {
        $sound = MotivationalSound::where('key', $key)->firstOrFail();

        $validated = $request->validate([
            'title' => 'nullable|string|max:100',
            'description' => 'nullable|string|max:255',
            'audio_file' => 'nullable|file|mimes:mp3,wav,m4a,aac,ogg,webm|max:15360',
            'is_active' => 'nullable|boolean',
        ]);

        if ($request->has('title') && $request->filled('title')) {
            $sound->title = $validated['title'];
        }
        if ($request->has('description')) {
            $sound->description = $validated['description'];
        }
        if ($request->has('is_active')) {
            $sound->is_active = $request->boolean('is_active');
        }

        if ($request->hasFile('audio_file')) {
            if ($sound->audio_path) {
                Storage::disk('public')->delete($sound->audio_path);
            }
            $path = $request->file('audio_file')->store('audio/motivation', 'public');
            $sound->audio_path = $path;
        }

        $sound->save();

        return redirect()->route('admin.sounds.index')
            ->with('success', "تم تحديث الصوت التحفيزي ({$sound->title}) بنجاح! 🔊");
    }

    public function destroy($key)
    {
        $sound = MotivationalSound::where('key', $key)->firstOrFail();

        if ($sound->audio_path) {
            Storage::disk('public')->delete($sound->audio_path);
            $sound->audio_path = null;
            $sound->save();
        }

        return redirect()->route('admin.sounds.index')
            ->with('success', "تم حذف المقطع الصوتي لـ ({$sound->title}) بنجاح.");
    }
}
