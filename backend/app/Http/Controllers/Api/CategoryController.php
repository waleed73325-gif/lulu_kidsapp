<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;

class CategoryController extends Controller
{
    /**
     * جلب قائمة الجزر والتصنيفات التعليمية
     */
    public function index()
    {
        $categories = Category::where('is_active', true)
            ->withCount(['lessons' => function ($q) {
                $q->where('is_published', true);
            }])
            ->orderBy('sort_order')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }
}
