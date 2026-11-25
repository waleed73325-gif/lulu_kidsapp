<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('educational_games', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->string('title', 191);
            $table->string('slug', 191)->unique();
            $table->text('description')->nullable();
            $table->string('game_type', 50)->default('letter_matching'); // letter_matching, letter_ordering, etc.
            $table->string('icon', 100)->default('videogame_asset_rounded');
            $table->string('primary_color', 20)->default('#6C5CE7');
            $table->enum('access_level', ['free', 'premium'])->default('free');
            $table->integer('stars_reward')->default(3);
            $table->integer('sort_order')->default(0);
            $table->boolean('is_published')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('educational_games');
    }
};
