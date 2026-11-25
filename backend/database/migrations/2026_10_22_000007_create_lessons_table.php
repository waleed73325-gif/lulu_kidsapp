<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lessons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('categories')->onDelete('cascade');
            $table->string('title', 191);
            $table->string('subtitle', 191)->nullable();
            $table->string('content_arabic', 50)->nullable();
            $table->string('example_word', 100)->nullable();
            $table->text('narration_text')->nullable();
            $table->string('display_icon', 100)->nullable();
            $table->string('primary_color', 20)->default('#6C5CE7');
            $table->enum('media_type', ['video', 'audio', 'interactive'])->default('interactive');
            $table->string('media_path', 255)->nullable();
            $table->enum('access_level', ['free', 'premium'])->default('free');
            $table->unsignedTinyInteger('stars_reward')->default(3);
            $table->integer('sort_order')->default(0);
            $table->boolean('is_published')->default(true);
            $table->timestamps();

            $table->index(['category_id', 'access_level', 'is_published'], 'idx_cat_access_pub');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lessons');
    }
};
