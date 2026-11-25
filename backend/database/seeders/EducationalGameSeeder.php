<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\EducationalGame;
use App\Models\GameQuestion;
use App\Models\Category;

class EducationalGameSeeder extends Seeder
{
    public function run(): void
    {
        $gamesCategory = Category::where('slug', 'cat_games')->first() 
            ?? Category::where('slug', 'cat_letters')->first();

        // 1. لعبة مطابقة الحروف الهجائية
        $matchingGame = EducationalGame::updateOrCreate(
            ['slug' => 'letter-matching-game'],
            [
                'category_id' => $gamesCategory?->id,
                'title' => 'لعبة مطابقة الحروف والكلمات',
                'description' => 'طابق الحرف والكلمة مع الصورة المناسبة واكسب النجوم البراقة!',
                'game_type' => 'letter_matching',
                'icon' => 'extension_rounded',
                'primary_color' => '#6C5CE7',
                'access_level' => 'free',
                'stars_reward' => 5,
                'sort_order' => 1,
                'is_published' => true,
            ]
        );

        $matchingQuestions = [
            [
                'title' => 'المرحلة 1: حرف الألف (أ)',
                'prompt' => 'أي بطاقة تبدأ بحرف الألف (أ)؟ 🐰',
                'hint' => 'حيوان أليف يحب الجزر ولديه أذنان طويلتان',
                'question_order' => 1,
                'payload' => [
                    'target_letter' => 'أ',
                    'target_word' => 'أرنب',
                    'target_emoji' => '🐰',
                    'options' => [
                        ['id' => '1', 'text' => 'أ', 'subtext' => 'أرنب', 'emoji' => '🐰', 'is_correct' => true],
                        ['id' => '2', 'text' => 'ب', 'subtext' => 'بطة', 'emoji' => '🦆', 'is_correct' => false],
                        ['id' => '3', 'text' => 'ت', 'subtext' => 'تمساح', 'emoji' => '🐊', 'is_correct' => false],
                    ],
                ],
            ],
            [
                'title' => 'المرحلة 2: حرف الباء (ب)',
                'prompt' => 'طابق حرف الباء (ب) مع الصورة اللطيفة! 🦆',
                'hint' => 'طائر جميل يسبح في الماء ويقول واك واك',
                'question_order' => 2,
                'payload' => [
                    'target_letter' => 'ب',
                    'target_word' => 'بطة',
                    'target_emoji' => '🦆',
                    'options' => [
                        ['id' => '1', 'text' => 'س', 'subtext' => 'سيارة', 'emoji' => '🚗', 'is_correct' => false],
                        ['id' => '2', 'text' => 'ب', 'subtext' => 'بطة', 'emoji' => '🦆', 'is_correct' => true],
                        ['id' => '3', 'text' => 'ج', 'subtext' => 'جمل', 'emoji' => '🐪', 'is_correct' => false],
                    ],
                ],
            ],
            [
                'title' => 'المرحلة 3: حرف التاء (ت)',
                'prompt' => 'اختر الحرف المطابق لفاكهة التفاح الشهية! 🍎',
                'hint' => 'فاكهة لذيذة ومفيدة تحب أكلها صباحاً',
                'question_order' => 3,
                'payload' => [
                    'target_letter' => 'ت',
                    'target_word' => 'تفاح',
                    'target_emoji' => '🍎',
                    'options' => [
                        ['id' => '1', 'text' => 'د', 'subtext' => 'دب', 'emoji' => '🐻', 'is_correct' => false],
                        ['id' => '2', 'text' => 'ز', 'subtext' => 'زرافة', 'emoji' => '🦒', 'is_correct' => false],
                        ['id' => '3', 'text' => 'ت', 'subtext' => 'تفاح', 'emoji' => '🍎', 'is_correct' => true],
                    ],
                ],
            ],
            [
                'title' => 'المرحلة 4: حرف الجيم (ج)',
                'prompt' => 'أين بطاقة سفينة الصحراء الجمل بحرف الجيم؟ 🐪',
                'hint' => 'يتحمل العطش ويمشي في رمال الصحراء',
                'question_order' => 4,
                'payload' => [
                    'target_letter' => 'ج',
                    'target_word' => 'جمل',
                    'target_emoji' => '🐪',
                    'options' => [
                        ['id' => '1', 'text' => 'ج', 'subtext' => 'جمل', 'emoji' => '🐪', 'is_correct' => true],
                        ['id' => '2', 'text' => 'ف', 'subtext' => 'فيل', 'emoji' => '🐘', 'is_correct' => false],
                        ['id' => '3', 'text' => 'ش', 'subtext' => 'شجرة', 'emoji' => '🌳', 'is_correct' => false],
                    ],
                ],
            ],
        ];

        // حذف الأسئلة القديمة وإعادة تعبئتها لضمان النظافة
        $matchingGame->questions()->delete();
        foreach ($matchingQuestions as $q) {
            $matchingGame->questions()->create($q);
        }

        // 2. لعبة ترتيب حروف الكلمة
        $orderingGame = EducationalGame::updateOrCreate(
            ['slug' => 'letter-ordering-game'],
            [
                'category_id' => $gamesCategory?->id,
                'title' => 'لعبة ترتيب حروف الكلمات',
                'description' => 'رتّب الحروف المبعثرة بالترتيب الصحيح لتكوين الكلمة المفيدة!',
                'game_type' => 'letter_ordering',
                'icon' => 'sort_by_alpha_rounded',
                'primary_color' => '#00B894',
                'access_level' => 'free',
                'stars_reward' => 5,
                'sort_order' => 2,
                'is_published' => true,
            ]
        );

        $orderingQuestions = [
            [
                'title' => 'المرحلة 1: كلمة أرنب',
                'prompt' => 'رتّب حروف كلمة (أَرْنَب) يا بطل 🐰',
                'hint' => 'ابدأ بحرف الألف ثم الراء ثم النون ثم الباء',
                'question_order' => 1,
                'payload' => [
                    'target_word' => 'أرنب',
                    'hint_emoji' => '🐰',
                    'scrambled_letters' => ['ن', 'أ', 'ب', 'ر'],
                    'correct_order' => ['أ', 'ر', 'ن', 'ب'],
                ],
            ],
            [
                'title' => 'المرحلة 2: كلمة قَلَم',
                'prompt' => 'رتّب حروف كلمة (قَلَم) التي نكتب ونرسم بها ✏️',
                'hint' => 'قاف ثم لام ثم ميم',
                'question_order' => 2,
                'payload' => [
                    'target_word' => 'قلم',
                    'hint_emoji' => '✏️',
                    'scrambled_letters' => ['م', 'ق', 'ل'],
                    'correct_order' => ['ق', 'ل', 'م'],
                ],
            ],
            [
                'title' => 'المرحلة 3: كلمة شَمْس',
                'prompt' => 'رتّب حروف كلمة (شَمْس) المشرقة والدافئة ☀️',
                'hint' => 'شين ثم ميم ثم سين',
                'question_order' => 3,
                'payload' => [
                    'target_word' => 'شمس',
                    'hint_emoji' => '☀️',
                    'scrambled_letters' => ['س', 'ش', 'م'],
                    'correct_order' => ['ش', 'م', 'س'],
                ],
            ],
            [
                'title' => 'المرحلة 4: كلمة نَجْم',
                'prompt' => 'رتّب حروف كلمة (نَجْم) الساطعة في السماء ⭐',
                'hint' => 'نون ثم جيم ثم ميم',
                'question_order' => 4,
                'payload' => [
                    'target_word' => 'نجم',
                    'hint_emoji' => '⭐',
                    'scrambled_letters' => ['م', 'ج', 'ن'],
                    'correct_order' => ['ن', 'ج', 'م'],
                ],
            ],
        ];

        $orderingGame->questions()->delete();
        foreach ($orderingQuestions as $q) {
            $orderingGame->questions()->create($q);
        }
    }
}
