<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\EducationalGame;
use App\Models\GameQuestion;

class AdminGameQuestionController extends Controller
{
    public function index(EducationalGame $game)
    {
        $questions = $game->questions()->orderBy('question_order')->get();
        return view('admin.games.questions.index', compact('game', 'questions'));
    }

    public function create(EducationalGame $game)
    {
        $nextOrder = ($game->questions()->max('question_order') ?? 0) + 1;
        $question = new GameQuestion([
            'game_id' => $game->id,
            'question_order' => $nextOrder,
            'is_active' => true,
            'title' => "المرحلة {$nextOrder}",
        ]);

        return view('admin.games.questions.form', compact('game', 'question'));
    }

    public function store(Request $request, EducationalGame $game)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:191',
            'prompt' => 'required|string|max:255',
            'hint' => 'nullable|string|max:255',
            'question_order' => 'required|integer|min:1',
            'is_active' => 'nullable|boolean',
            'audio_file' => 'nullable|file|mimes:mp3,wav,ogg,m4a,aac|max:15360',
            // fields for letter_matching
            'target_letter' => 'nullable|string',
            'target_word' => 'nullable|string',
            'target_emoji' => 'nullable|string',
            'option_letter' => 'nullable|array',
            'option_word' => 'nullable|array',
            'option_emoji' => 'nullable|array',
            'correct_option_index' => 'nullable|integer',
            // fields for letter_ordering
            'ordering_word' => 'nullable|string',
            'ordering_emoji' => 'nullable|string',
            'scrambled_letters' => 'nullable|string',
            // or direct JSON payload
            'raw_payload' => 'nullable|string',
        ]);

        $payload = $this->buildPayload($game->game_type, $request);

        $audioPath = null;
        if ($request->hasFile('audio_file')) {
            $audioPath = $request->file('audio_file')->store('audio/games', 'public');
        }

        $game->questions()->create([
            'title' => $validated['title'],
            'prompt' => $validated['prompt'],
            'hint' => $validated['hint'] ?? null,
            'question_order' => $validated['question_order'],
            'is_active' => $request->has('is_active'),
            'payload' => $payload,
            'audio_path' => $audioPath,
        ]);

        return redirect()->route('admin.games.questions.index', $game->id)
            ->with('success', 'تمت إضافة المرحلة / السؤال بنجاح.');
    }

    public function edit(EducationalGame $game, GameQuestion $question)
    {
        return view('admin.games.questions.form', compact('game', 'question'));
    }

    public function update(Request $request, EducationalGame $game, GameQuestion $question)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:191',
            'prompt' => 'required|string|max:255',
            'hint' => 'nullable|string|max:255',
            'question_order' => 'required|integer|min:1',
            'is_active' => 'nullable|boolean',
            'audio_file' => 'nullable|file|mimes:mp3,wav,ogg,m4a,aac|max:15360',
            'remove_audio' => 'nullable|boolean',
            // fields for letter_matching
            'target_letter' => 'nullable|string',
            'target_word' => 'nullable|string',
            'target_emoji' => 'nullable|string',
            'option_letter' => 'nullable|array',
            'option_word' => 'nullable|array',
            'option_emoji' => 'nullable|array',
            'correct_option_index' => 'nullable|integer',
            // fields for letter_ordering
            'ordering_word' => 'nullable|string',
            'ordering_emoji' => 'nullable|string',
            'scrambled_letters' => 'nullable|string',
            // or direct JSON payload
            'raw_payload' => 'nullable|string',
        ]);

        $payload = $this->buildPayload($game->game_type, $request, $question->payload);

        $audioPath = $question->audio_path;

        if ($request->has('remove_audio') && $request->remove_audio) {
            if ($audioPath && Storage::disk('public')->exists($audioPath)) {
                Storage::disk('public')->delete($audioPath);
            }
            $audioPath = null;
        }

        if ($request->hasFile('audio_file')) {
            if ($audioPath && Storage::disk('public')->exists($audioPath)) {
                Storage::disk('public')->delete($audioPath);
            }
            $audioPath = $request->file('audio_file')->store('audio/games', 'public');
        }

        $question->update([
            'title' => $validated['title'],
            'prompt' => $validated['prompt'],
            'hint' => $validated['hint'] ?? null,
            'question_order' => $validated['question_order'],
            'is_active' => $request->has('is_active'),
            'payload' => $payload,
            'audio_path' => $audioPath,
        ]);

        return redirect()->route('admin.games.questions.index', $game->id)
            ->with('success', 'تم تحديث المرحلة / السؤال بنجاح.');
    }

    public function destroy(EducationalGame $game, GameQuestion $question)
    {
        if ($question->audio_path && Storage::disk('public')->exists($question->audio_path)) {
            Storage::disk('public')->delete($question->audio_path);
        }

        $question->delete();

        return redirect()->route('admin.games.questions.index', $game->id)
            ->with('success', 'تم حذف المرحلة بنجاح.');
    }

    private function buildPayload(string $gameType, Request $request, array $existingPayload = []): array
    {
        if ($request->filled('raw_payload')) {
            $decoded = json_decode($request->raw_payload, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        if ($gameType === 'letter_matching') {
            $options = [];
            $letters = $request->input('option_letter', []);
            $words = $request->input('option_word', []);
            $emojis = $request->input('option_emoji', []);
            $correctIdx = (int) $request->input('correct_option_index', 0);

            foreach ($letters as $idx => $letter) {
                if (!empty($letter)) {
                    $options[] = [
                        'id' => (string) ($idx + 1),
                        'text' => trim($letter),
                        'subtext' => trim($words[$idx] ?? ''),
                        'emoji' => trim($emojis[$idx] ?? '⭐'),
                        'is_correct' => ($idx === $correctIdx),
                    ];
                }
            }

            if (!empty($options)) {
                return [
                    'target_letter' => trim($request->input('target_letter', '')),
                    'target_word' => trim($request->input('target_word', '')),
                    'target_emoji' => trim($request->input('target_emoji', '⭐')),
                    'options' => $options,
                ];
            }
        }

        if ($gameType === 'letter_ordering') {
            $word = trim($request->input('ordering_word', ''));
            $emoji = trim($request->input('ordering_emoji', '⭐'));

            if (!empty($word)) {
                $correctLetters = preg_split('//u', $word, -1, PREG_SPLIT_NO_EMPTY);
                
                $scrambledStr = trim($request->input('scrambled_letters', ''));
                if (!empty($scrambledStr)) {
                    $scrambled = array_map('trim', explode(',', $scrambledStr));
                } else {
                    $scrambled = $correctLetters;
                    shuffle($scrambled);
                    // Ensure it is not immediately in the correct order if length > 1
                    if (count($scrambled) > 1 && $scrambled === $correctLetters) {
                        $temp = $scrambled[0];
                        $scrambled[0] = $scrambled[count($scrambled) - 1];
                        $scrambled[count($scrambled) - 1] = $temp;
                    }
                }

                return [
                    'target_word' => $word,
                    'hint_emoji' => $emoji,
                    'scrambled_letters' => array_values($scrambled),
                    'correct_order' => array_values($correctLetters),
                ];
            }
        }

        return $existingPayload ?: ['data' => []];
    }
}
