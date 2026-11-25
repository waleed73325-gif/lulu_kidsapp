<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MotivationalSound;

class MotivationalSoundController extends Controller
{
    /**
     * جلب قائمة روابط المقاطع الصوتية التحفيزية المتاحة على الخادم
     */
    public function index()
    {
        $sounds = MotivationalSound::where('is_active', true)->get();

        $data = [];
        foreach ($sounds as $sound) {
            $data[$sound->key] = [
                'title' => $sound->title,
                'audio_url' => $sound->audio_url,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }
}
