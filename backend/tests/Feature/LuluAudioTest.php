<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;
use App\Models\User;
use App\Models\Category;
use App\Models\Lesson;
use App\Models\MotivationalSound;

class LuluAudioTest extends TestCase
{
    use DatabaseTransactions;

    public function test_can_fetch_motivational_sounds_via_api(): void
    {
        $response = $this->getJson('/api/v1/motivational-sounds');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'data' => [
                    'stars_reward',
                    'cheer',
                    'correct_answer',
                    'welcome',
                ]
            ]);
    }

    public function test_admin_can_view_motivational_sounds_management(): void
    {
        $admin = User::where('role', 'admin')->first();

        $response = $this->actingAs($admin)->get('/admin/sounds');

        $response->assertStatus(200)
            ->assertSee('الأصوات التحفيزية')
            ->assertSee('stars_reward');
    }

    public function test_admin_can_upload_motivational_sound(): void
    {
        Storage::fake('public');

        $admin = User::where('role', 'admin')->first();
        $file = UploadedFile::fake()->create('reward.mp3', 200, 'audio/mpeg');

        $response = $this->actingAs($admin)->post('/admin/sounds/stars_reward', [
            'audio_file' => $file,
        ]);

        $response->assertRedirect('/admin/sounds');
        
        $sound = MotivationalSound::where('key', 'stars_reward')->first();
        $this->assertNotNull($sound->audio_path);
        Storage::disk('public')->assertExists($sound->audio_path);
    }

    public function test_admin_can_upload_lesson_audio(): void
    {
        Storage::fake('public');

        $admin = User::where('role', 'admin')->first();
        $category = Category::first();
        $file = UploadedFile::fake()->create('letter_a.mp3', 300, 'audio/mpeg');

        $response = $this->actingAs($admin)->post('/admin/lessons', [
            'category_id' => $category->id,
            'title' => 'حرف الألف الجديد',
            'content_arabic' => 'أ',
            'example_word' => 'أرنب',
            'primary_color' => '#FF7675',
            'media_type' => 'interactive',
            'access_level' => 'free',
            'stars_reward' => 3,
            'sort_order' => 1,
            'audio_file' => $file,
        ]);

        $response->assertRedirect('/admin/lessons');

        $lesson = Lesson::where('title', 'حرف الألف الجديد')->first();
        $this->assertNotNull($lesson);
        $this->assertNotNull($lesson->audio_path);
        Storage::disk('public')->assertExists($lesson->audio_path);
    }
}
