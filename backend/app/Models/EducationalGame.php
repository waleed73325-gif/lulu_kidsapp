<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class EducationalGame extends Model
{
    use HasFactory;

    protected $table = 'educational_games';

    protected $fillable = [
        'category_id',
        'title',
        'slug',
        'description',
        'game_type',
        'icon',
        'primary_color',
        'access_level',
        'stars_reward',
        'sort_order',
        'is_published',
    ];

    protected $casts = [
        'is_published' => 'boolean',
        'stars_reward' => 'integer',
        'sort_order' => 'integer',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function questions(): HasMany
    {
        return $this->hasMany(GameQuestion::class, 'game_id')->orderBy('question_order');
    }

    public function activeQuestions(): HasMany
    {
        return $this->hasMany(GameQuestion::class, 'game_id')
            ->where('is_active', true)
            ->orderBy('question_order');
    }

    public function isFree(): bool
    {
        return $this->access_level === 'free';
    }

    public function getGameTypeNameAttribute(): string
    {
        return match ($this->game_type) {
            'letter_matching' => 'مطابقة الحروف والكلمات',
            'letter_ordering' => 'ترتيب حروف الكلمة',
            default => 'لعبة تفاعلية متنوعة',
        };
    }
}
