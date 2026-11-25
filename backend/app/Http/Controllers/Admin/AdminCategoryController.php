<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;
use Illuminate\Support\Str;

class AdminCategoryController extends Controller
{
    public function index()
    {
        $categories = Category::withCount('lessons')->orderBy('sort_order')->get();
        return view('admin.categories.index', compact('categories'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name_ar' => 'required|string|max:100',
            'subtitle_ar' => 'nullable|string|max:191',
            'slug' => 'nullable|string|max:100|unique:categories,slug',
            'icon' => 'nullable|string|max:100',
            'sort_order' => 'required|integer|min:0',
        ]);

        if (empty($validated['slug'])) {
            $validated['slug'] = 'cat_' . Str::slug($validated['name_ar']) . '_' . rand(100, 999);
        }

        $validated['is_active'] = $request->has('is_active');

        Category::create($validated);

        return redirect()->route('admin.categories.index')
            ->with('success', 'تمت إضافة الجزيرة/التصنيف بنجاح! 🏝️');
    }

    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $validated = $request->validate([
            'name_ar' => 'required|string|max:100',
            'subtitle_ar' => 'nullable|string|max:191',
            'icon' => 'nullable|string|max:100',
            'sort_order' => 'required|integer|min:0',
        ]);

        $validated['is_active'] = $request->has('is_active');
        $category->update($validated);

        return redirect()->route('admin.categories.index')
            ->with('success', 'تم تحديث بيانات التصنيف بنجاح.');
    }

    public function destroy($id)
    {
        $category = Category::findOrFail($id);
        $category->delete();

        return redirect()->route('admin.categories.index')
            ->with('success', 'تم حذف التصنيف بنجاح.');
    }
}
