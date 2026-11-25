<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Child;
use App\Models\Plan;
use App\Models\Category;
use App\Models\Lesson;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. خطط الاشتراك
        $plan3m = Plan::updateOrCreate(
            ['slug' => 'starter-3m'],
            [
                'name' => 'باقة 3 أشهر',
                'duration_days' => 90,
                'price' => 29.00,
                'currency' => 'SAR',
                'description' => 'مناسبة لتجربة المحتوى التعليمي',
                'is_active' => true,
            ]
        );

        $plan1y = Plan::updateOrCreate(
            ['slug' => 'full-1y'],
            [
                'name' => 'باقة السنة الكاملة (12 شهراً)',
                'duration_days' => 365,
                'price' => 89.00,
                'currency' => 'SAR',
                'description' => 'أفضل توفير - سنة كاملة من المرح والتعلم',
                'is_active' => true,
            ]
        );

        // 2. تصنيفات وجزر لولو
        $catLetters = Category::updateOrCreate(
            ['slug' => 'cat_letters'],
            [
                'name_ar' => 'جزيرة الحروف',
                'subtitle_ar' => 'تعلم نطق وكتابة الحروف العربية مع لولو',
                'icon' => 'sort_by_alpha_rounded',
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        $catNumbers = Category::updateOrCreate(
            ['slug' => 'cat_numbers'],
            [
                'name_ar' => 'جزيرة الأرقام والعد',
                'subtitle_ar' => 'هيا نعد النجوم والألعاب سوياً',
                'icon' => 'pin_outlined',
                'sort_order' => 2,
                'is_active' => true,
            ]
        );

        $catColors = Category::updateOrCreate(
            ['slug' => 'cat_colors'],
            [
                'name_ar' => 'جزيرة الألوان والأشكال',
                'subtitle_ar' => 'اكتشف عالم الألوان المبهج',
                'icon' => 'palette_outlined',
                'sort_order' => 3,
                'is_active' => true,
            ]
        );

        $catStories = Category::updateOrCreate(
            ['slug' => 'cat_stories'],
            [
                'name_ar' => 'خيمة حكايات لولو',
                'subtitle_ar' => 'قصص مرحة ومغامرات تعليمية جميلة',
                'icon' => 'menu_book_rounded',
                'sort_order' => 4,
                'is_active' => true,
            ]
        );

        $catGames = Category::updateOrCreate(
            ['slug' => 'cat_games'],
            [
                'name_ar' => 'حديقة ألعاب لولو',
                'subtitle_ar' => 'أنشطة مطابقة واختيار ذكية وممتعة',
                'icon' => 'videogame_asset_outlined',
                'sort_order' => 5,
                'is_active' => true,
            ]
        );

        // 3. أول 20 درساً مخططاً في نطاق MVP
        $lessonsData = [
            // الحروف
            [
                'category_id' => $catLetters->id,
                'title' => 'حرف الألف (أ)',
                'subtitle' => 'أ - أرنب',
                'content_arabic' => 'أ',
                'example_word' => 'أرنب 🐰',
                'narration_text' => 'مرحباً يا بطل! أنا صديقك لولو، وأول حرف في اسمي هو حرف الألف.. أ، أ، أرنب!',
                'display_icon' => 'pets_rounded',
                'primary_color' => '#FF7675',
                'access_level' => 'free',
                'sort_order' => 1,
            ],
            [
                'category_id' => $catLetters->id,
                'title' => 'حرف الباء (ب)',
                'subtitle' => 'ب - بطة',
                'content_arabic' => 'ب',
                'example_word' => 'بطة 🦆',
                'narration_text' => 'حرف الباء تحته نقطة واحدة جميلة.. ب، ب، بطة تسبح في الماء!',
                'display_icon' => 'flutter_dash_rounded',
                'primary_color' => '#00CEC9',
                'access_level' => 'free',
                'sort_order' => 2,
            ],
            [
                'category_id' => $catLetters->id,
                'title' => 'حرف التاء (ت)',
                'subtitle' => 'ت - تفاحة',
                'content_arabic' => 'ت',
                'example_word' => 'تفاحة 🍎',
                'narration_text' => 'حرف التاء وفوقه نقطتان كالعينين المبتسمتين.. ت، ت، تفاحة لذيذة!',
                'display_icon' => 'eco_rounded',
                'primary_color' => '#E17055',
                'access_level' => 'free',
                'sort_order' => 3,
            ],
            [
                'category_id' => $catLetters->id,
                'title' => 'حرف الثاء (ث)',
                'subtitle' => 'ث - ثعلب',
                'content_arabic' => 'ث',
                'example_word' => 'ثعلب 🦊',
                'narration_text' => 'أخرج طرف لسانك بلطف عند نطق الثاء.. ث، ث، ثعلب ذكي وسريع!',
                'display_icon' => 'cruelty_free_rounded',
                'primary_color' => '#6C5CE7',
                'access_level' => 'premium',
                'sort_order' => 4,
            ],
            [
                'category_id' => $catLetters->id,
                'title' => 'حرف الجيم (ج)',
                'subtitle' => 'ج - جمل',
                'content_arabic' => 'ج',
                'example_word' => 'جمل 🐪',
                'narration_text' => 'الجمل سفينة الصحراء، وحرف الجيم في بطنه نقطة!',
                'display_icon' => 'terrain_rounded',
                'primary_color' => '#FDCB6E',
                'access_level' => 'premium',
                'sort_order' => 5,
            ],
            [
                'category_id' => $catLetters->id,
                'title' => 'حرف الحاء (ح)',
                'subtitle' => 'ح - حصان',
                'content_arabic' => 'ح',
                'example_word' => 'حصان 🐎',
                'narration_text' => 'حرف الحاء قوي وأصيل مثل الحصان السريع!',
                'display_icon' => 'directions_run_rounded',
                'primary_color' => '#0984E3',
                'access_level' => 'premium',
                'sort_order' => 6,
            ],

            // الأرقام
            [
                'category_id' => $catNumbers->id,
                'title' => 'الرقم واحد (١)',
                'subtitle' => '١ - قمر واحد',
                'content_arabic' => '١',
                'example_word' => 'قمر واحد 🌙',
                'narration_text' => 'الرقم واحد يقف مستقيماً كالبطل! مثل قمر واحد ينير ليلنا.',
                'display_icon' => 'brightness_3_rounded',
                'primary_color' => '#0984E3',
                'access_level' => 'free',
                'sort_order' => 1,
            ],
            [
                'category_id' => $catNumbers->id,
                'title' => 'الرقم اثنان (٢)',
                'subtitle' => '٢ - عينان نرى بهما',
                'content_arabic' => '٢',
                'example_word' => 'عينان جميلتان 👀',
                'narration_text' => 'الرقم اثنان ينظر إلى الواحد بلطف.. عينان اثنتان نرى بهما الكون الجميل!',
                'display_icon' => 'visibility_rounded',
                'primary_color' => '#00B894',
                'access_level' => 'free',
                'sort_order' => 2,
            ],
            [
                'category_id' => $catNumbers->id,
                'title' => 'الرقم ثلاثة (٣)',
                'subtitle' => '٣ - ثلاث سمكات',
                'content_arabic' => '٣',
                'example_word' => 'ثلاث سمكات 🐟',
                'narration_text' => 'الرقم ثلاثة يملك أسناناً تبتسم.. واحد، اثنان، ثلاثة!',
                'display_icon' => 'water_rounded',
                'primary_color' => '#FDCB6E',
                'access_level' => 'premium',
                'sort_order' => 3,
            ],
            [
                'category_id' => $catNumbers->id,
                'title' => 'الرقم أربعة (٤)',
                'subtitle' => '٤ - أربع فراشات',
                'content_arabic' => '٤',
                'example_word' => 'أربع فراشات 🦋',
                'narration_text' => 'أربع فراشات ملونة تطير في الحديقة السعيدة!',
                'display_icon' => 'nature_people_rounded',
                'primary_color' => '#FD79A8',
                'access_level' => 'premium',
                'sort_order' => 4,
            ],
            [
                'category_id' => $catNumbers->id,
                'title' => 'الرقم خمسة (٥)',
                'subtitle' => '٥ - خمس أصابع',
                'content_arabic' => '٥',
                'example_word' => 'أصابع اليد الواحدة ✋',
                'narration_text' => 'خمسة كالدائرة اللطيفة، تماماً كأصابع كفك الواحدة!',
                'display_icon' => 'front_hand_rounded',
                'primary_color' => '#6C5CE7',
                'access_level' => 'premium',
                'sort_order' => 5,
            ],

            // الألوان والأشكال
            [
                'category_id' => $catColors->id,
                'title' => 'اللون الأحمر',
                'subtitle' => 'أحمر كالورد والفراولة',
                'content_arabic' => 'أحمر',
                'example_word' => 'فراولة حمراء 🍓',
                'narration_text' => 'ما أجمل اللون الأحمر! مثل الفراولة الشهية والقلوب الدافئة.',
                'display_icon' => 'favorite_rounded',
                'primary_color' => '#D63031',
                'access_level' => 'free',
                'sort_order' => 1,
            ],
            [
                'category_id' => $catColors->id,
                'title' => 'الدائرة الصفراء',
                'subtitle' => 'شكل دائري كقرص الشمس',
                'content_arabic' => 'دائرة',
                'example_word' => 'شمس مشرقة ☀️',
                'narration_text' => 'الدائرة تلف وتدور دون زوايا.. تماماً كقرص الشمس الدافئ!',
                'display_icon' => 'circle',
                'primary_color' => '#FDCB6E',
                'access_level' => 'premium',
                'sort_order' => 2,
            ],
            [
                'category_id' => $catColors->id,
                'title' => 'المربع الأخضر',
                'subtitle' => 'أربعة أضلاع متساوية',
                'content_arabic' => 'مربع',
                'example_word' => 'هدية خضراء 🎁',
                'narration_text' => 'المربع له أربعة أضلاع متطابقة كصندوق الهدايا الجميل!',
                'display_icon' => 'crop_square_rounded',
                'primary_color' => '#00B894',
                'access_level' => 'premium',
                'sort_order' => 3,
            ],

            // القصص
            [
                'category_id' => $catStories->id,
                'title' => 'لولو والجزرة المفقودة',
                'subtitle' => 'قصة قصيرة عن الصدق ومساعدة الأصدقاء',
                'content_arabic' => 'قصة',
                'example_word' => 'لولو والأصدقاء',
                'narration_text' => 'في يوم مشمس وجميل، خرج الأرنب لولو للبحث عن جزرته البرتقالية..',
                'display_icon' => 'auto_stories_rounded',
                'primary_color' => '#6C5CE7',
                'access_level' => 'free',
                'sort_order' => 1,
            ],
            [
                'category_id' => $catStories->id,
                'title' => 'مغامرة صديق لولو في الغابة',
                'subtitle' => 'قصة عن الشجاعة والتعاون',
                'content_arabic' => 'قصة',
                'example_word' => 'صديق لولو 🐿️',
                'narration_text' => 'التقى لولو بصديقه السنجاب في حديقة البلوط، وقررا بناء بيت صغير..',
                'display_icon' => 'park_rounded',
                'primary_color' => '#E17055',
                'access_level' => 'premium',
                'sort_order' => 2,
            ],

            // الألعاب
            [
                'category_id' => $catGames->id,
                'title' => 'لعبة مطابقة الحروف',
                'subtitle' => 'طابق الحرف مع صورته الصحيحة',
                'content_arabic' => 'لعبة',
                'example_word' => 'مطابقة وتفكير',
                'narration_text' => 'اختر الحرف الذي يبدأ به اسم الحيوان لتكسب نجوماً ذهبية!',
                'display_icon' => 'extension_rounded',
                'primary_color' => '#00CEC9',
                'access_level' => 'free',
                'sort_order' => 1,
            ],
            [
                'category_id' => $catGames->id,
                'title' => 'تحدي عد النجوم',
                'subtitle' => 'كم نجمة ساطعة في السماء؟',
                'content_arabic' => 'لعبة',
                'example_word' => 'عد واكتشف',
                'narration_text' => 'المس النجوم اللامعة وعدّها واحدة تلو الأخرى مع لولو!',
                'display_icon' => 'stars_rounded',
                'primary_color' => '#FDCB6E',
                'access_level' => 'premium',
                'sort_order' => 2,
            ],
        ];

        foreach ($lessonsData as $data) {
            Lesson::updateOrCreate(
                [
                    'category_id' => $data['category_id'],
                    'title' => $data['title'],
                ],
                $data
            );
        }

        // 4. مستخدم تجريبي لولي الأمر
        $demoParent = User::updateOrCreate(
            ['email' => 'parent@lulukids.com'],
            [
                'name' => 'أحمد ولي الأمر',
                'phone' => '0501234567',
                'password' => Hash::make('password123'),
                'role' => 'parent',
                'status' => 'active',
            ]
        );

        // طفل تجريبي مرتبط بولي الأمر
        Child::updateOrCreate(
            [
                'parent_user_id' => $demoParent->id,
                'nickname' => 'البطل الصغير',
            ],
            [
                'birth_year' => 2021,
                'avatar_id' => 'rabbit_lulu',
            ]
        );

        // 5. حساب مدير النظام (Admin) للوحة التحكم
        User::updateOrCreate(
            ['email' => 'admin@lulukids.com'],
            [
                'name' => 'مدير نظام لولو',
                'phone' => '0500000000',
                'password' => Hash::make('admin123456'),
                'role' => 'admin',
                'status' => 'active',
            ]
        );

        // 6. الأصوات التحفيزية الافتراضية
        $this->call(MotivationalSoundSeeder::class);

        // 7. الألعاب التعليمية ومراحلها
        $this->call(EducationalGameSeeder::class);
    }
}
