<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Plan;
use Illuminate\Support\Str;

class AdminPlanController extends Controller
{
    /**
     * عرض جميع باقات الاشتراك
     */
    public function index()
    {
        $plans = Plan::withCount(['orders', 'orders as active_subscribers_count' => function ($q) {
            $q->whereHas('subscription', function ($sub) {
                $sub->where('status', 'active')->where('ends_at', '>', now());
            });
        }])->orderBy('price', 'asc')->get();

        return view('admin.plans.index', compact('plans'));
    }

    /**
     * نموذج إضافة باقة جديدة
     */
    public function create()
    {
        $plan = new Plan([
            'currency' => 'SAR',
            'duration_days' => 30,
            'price' => 19.00,
            'is_active' => true,
        ]);
        $isEdit = false;

        return view('admin.plans.form', compact('plan', 'isEdit'));
    }

    /**
     * حفظ باقة جديدة
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'slug' => 'nullable|string|max:100|unique:plans,slug',
            'duration_days' => 'required|integer|min:1|max:3650',
            'price' => 'required|numeric|min:0|max:99999.99',
            'currency' => 'required|string|max:10',
            'description' => 'nullable|string|max:500',
            'is_active' => 'nullable|boolean',
        ]);

        if (empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']) ?: 'plan-' . time();
        }

        $validated['is_active'] = $request->has('is_active');

        Plan::create($validated);

        return redirect()->route('admin.plans.index')
            ->with('success', 'تمت إضافة باقة الاشتراك بنجاح! ✨');
    }

    /**
     * نموذج تعديل الباقة
     */
    public function edit(Plan $plan)
    {
        $isEdit = true;
        return view('admin.plans.form', compact('plan', 'isEdit'));
    }

    /**
     * تحديث بيانات الباقة
     */
    public function update(Request $request, Plan $plan)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'slug' => 'required|string|max:100|unique:plans,slug,' . $plan->id,
            'duration_days' => 'required|integer|min:1|max:3650',
            'price' => 'required|numeric|min:0|max:99999.99',
            'currency' => 'required|string|max:10',
            'description' => 'nullable|string|max:500',
            'is_active' => 'nullable|boolean',
        ]);

        $validated['is_active'] = $request->has('is_active');

        $plan->update($validated);

        return redirect()->route('admin.plans.index')
            ->with('success', 'تم تحديث بيانات باقة الاشتراك بنجاح! ✨');
    }

    /**
     * تبديل حالة التفعيل
     */
    public function toggle(Plan $plan)
    {
        $plan->update(['is_active' => !$plan->is_active]);

        $status = $plan->is_active ? 'تفعيل' : 'تعطيل';
        return back()->with('success', "تم {$status} الباقة بنجاح.");
    }

    /**
     * حذف الباقة
     */
    public function destroy(Plan $plan)
    {
        if ($plan->orders()->exists()) {
            return back()->with('error', 'لا يمكن حذف هذه الباقة لوجود طلبات واشتراكات مرتبطة بها، يمكنك تعطيلها بدلاً من حذفها.');
        }

        $plan->delete();
        return redirect()->route('admin.plans.index')
            ->with('success', 'تم حذف الباقة بنجاح.');
    }
}
