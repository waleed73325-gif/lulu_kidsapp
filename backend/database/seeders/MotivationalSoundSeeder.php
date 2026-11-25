<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\MotivationalSound;

class MotivationalSoundSeeder extends Seeder
{
    public function run(): void
    {
        $sounds = [
            [
                'key' => 'stars_reward',
                'title' => 'صوت جمع النجوم وإكمال الدرس',
                'description' => 'يُعزف تلقائياً للطفل عند إنهاء الدرس بنجاح ومكافأته بالنجوم اللامعة.',
            ],
            [
                'key' => 'cheer',
                'title' => 'صوت التشجيع الحماسي (كفو يا بطل)',
                'description' => 'يُعزف لتحفيز وبث الحماس في الطفل أثناء التعلم والتفاعل.',
            ],
            [
                'key' => 'correct_answer',
                'title' => 'صوت الإجابة الصحيحة والإنجاز',
                'description' => 'يُعزف عند مطابقة الطفل للإجابة أو الحرف أو الرقم الصحيح.',
            ],
            [
                'key' => 'welcome',
                'title' => 'صوت الترحيب بالطفل',
                'description' => 'يُعزف ترحيباً بالبطل الصغير عند بدء الاستكشاف.',
            ],
        ];

        foreach ($sounds as $sound) {
            MotivationalSound::firstOrCreate(
                ['key' => $sound['key']],
                [
                    'title' => $sound['title'],
                    'description' => $sound['description'],
                    'is_active' => true,
                ]
            );
        }
    }
}
