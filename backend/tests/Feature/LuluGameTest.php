<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;
use App\Models\User;
use App\Models\EducationalGame;
use App\Models\GameQuestion;

class LuluGameTest extends TestCase
{
    use DatabaseTransactions;

    public function test_can_fetch_games_via_api(): void
    {
        $response = $this->getJson('/api/v1/games');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'success',
                'count',
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'slug',
                        'game_type',
                        'stars_reward',
                        'active_questions_count',
                    ]
                ]
            ]);
    }

    public function test_can_fetch_game_details_with_questions_via_api(): void
    {
        $game = EducationalGame::first();
        $this->assertNotNull($game);

        $response = $this->getJson("/api/v1/games/{$game->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $game->id,
                    'title' => $game->title,
                ]
            ])
            ->assertJsonStructure([
                'data' => [
                    'active_questions' => [
                        '*' => [
                            'id',
                            'title',
                            'prompt',
                            'question_order',
                            'payload',
                        ]
                    ]
                ]
            ]);
    }

    public function test_admin_can_view_games_list(): void
    {
        $admin = User::where('role', 'admin')->first();

        $response = $this->actingAs($admin)->get('/admin/games');

        $response->assertStatus(200)
            ->assertSee('الألعاب التعليمية')
            ->assertSee('مطابقة الحروف');
    }

    public function test_admin_can_create_new_game(): void
    {
        $admin = User::where('role', 'admin')->first();

        $response = $this->actingAs($admin)->post('/admin/games', [
            'title' => 'لعبة ترتيب الألوان والأشكال',
            'game_type' => 'letter_ordering',
            'icon' => 'palette_outlined',
            'primary_color' => '#FF7675',
            'access_level' => 'free',
            'stars_reward' => 5,
            'sort_order' => 10,
            'is_published' => 1,
        ]);

        $created = EducationalGame::where('title', 'لعبة ترتيب الألوان والأشكال')->first();
        $this->assertNotNull($created);
        $response->assertRedirect("/admin/games/{$created->id}/questions");
    }

    public function test_admin_can_add_question_with_audio_to_game(): void
    {
        Storage::fake('public');
        $admin = User::where('role', 'admin')->first();
        $game = EducationalGame::first();

        $audioFile = UploadedFile::fake()->create('prompt.mp3', 200, 'audio/mpeg');

        $response = $this->actingAs($admin)->post("/admin/games/{$game->id}/questions", [
            'title' => 'مرحلة اختبار جديدة',
            'prompt' => 'أي بطاقة تمثل صوت الحرف؟',
            'hint' => 'استمع جيداً',
            'question_order' => 99,
            'is_active' => 1,
            'target_letter' => 'ج',
            'target_word' => 'جمل',
            'target_emoji' => '🐪',
            'option_letter' => ['ج', 'ح', 'خ'],
            'option_word' => ['جمل', 'حصان', 'خروف'],
            'option_emoji' => ['🐪', '🐎', '🐑'],
            'correct_option_index' => 0,
            'audio_file' => $audioFile,
        ]);

        $response->assertRedirect("/admin/games/{$game->id}/questions");

        $question = GameQuestion::where('title', 'مرحلة اختبار جديدة')->first();
        $this->assertNotNull($question);
        $this->assertNotNull($question->audio_path);
        Storage::disk('public')->assertExists($question->audio_path);
        $this->assertEquals('ج', $question->payload['target_letter']);
        $this->assertTrue($question->payload['options'][0]['is_correct']);
    }
}
