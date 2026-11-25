<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('game_questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('game_id')->constrained('educational_games')->cascadeOnDelete();
            $table->string('title', 191);
            $table->string('prompt', 255);
            $table->string('hint', 255)->nullable();
            $table->integer('question_order')->default(1);
            $table->json('payload'); // Stores options, target items, scrambled letters, etc.
            $table->string('audio_path')->nullable(); // Optional voice prompt audio
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('game_questions');
    }
};
