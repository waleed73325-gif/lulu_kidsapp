<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Child extends Model
{
    use HasFactory;

    protected $fillable = [
        'parent_user_id',
        'nickname',
        'birth_year',
        'avatar_id',
        'stars_count',
        'completed_lessons',
    ];

    protected $casts = [
        'stars_count' => 'integer',
        'completed_lessons' => 'array',
    ];

    protected $attributes = [
        'stars_count' => 12,
        'completed_lessons' => '["let_1", "num_1"]',
    ];

    public function parent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'parent_user_id');
    }

    public function progress(): HasMany
    {
        return $this->hasMany(LessonProgress::class);
    }
}
