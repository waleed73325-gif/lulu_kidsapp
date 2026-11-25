<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GameQuestion extends Model
{
    use HasFactory;

    protected $table = 'game_questions';

    protected $fillable = [
        'game_id',
        'title',
        'prompt',
        'hint',
        'question_order',
        'payload',
        'audio_path',
        'is_active',
    ];

    protected $casts = [
        'payload' => 'array',
        'question_order' => 'integer',
        'is_active' => 'boolean',
    ];

    protected $appends = [
        'audio_url',
    ];

    public function game(): BelongsTo
    {
        return $this->belongsTo(EducationalGame::class, 'game_id');
    }

    public function getAudioUrlAttribute(): ?string
    {
        if (!$this->audio_path) {
            return null;
        }

        if (str_starts_with($this->audio_path, 'http://') || str_starts_with($this->audio_path, 'https://')) {
            return $this->audio_path;
        }

        return url('storage/' . ltrim($this->audio_path, '/'));
    }
}
