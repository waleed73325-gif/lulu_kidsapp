@extends('admin.layout')

@section('title', 'باقات الاشتراك (Lulu+)')
@section('page_title', 'إدارة خطط وباقات الاشتراك')

@section('content')
<div class="row g-4">
    <div class="col-12">
        <div class="card table-custom border-0 shadow-sm">
            <div class="card-body p-4">
                <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
                    <div>
                        <h6 class="fw-bold mb-1"><i class="fa-solid fa-crown text-warning me-2"></i>باقات الاشتراك المتاحة للآباء</h6>
                        <small class="text-muted">التحكم في أسعار الباقات والمدد الزمنية وتفعيلها في تطبيق فلاتر فورياً</small>
                    </div>
                    <a href="{{ route('admin.plans.create') }}" class="btn btn-lulu-primary">
                        <i class="fa-solid fa-plus me-1"></i> إضافة باقة جديدة
                    </a>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>اسم الباقة</th>
                                <th>المعرف البرمجي</th>
                                <th>المدة باليوم</th>
                                <th>السعر</th>
                                <th>المشتركون النشطون</th>
                                <th>إجمالي الطلبات</th>
                                <th>الحالة</th>
                                <th>العمليات</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($plans as $plan)
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark fs-6">{{ $plan->name }}</div>
                                        @if($plan->description)
                                            <small class="text-muted">{{ Str::limit($plan->description, 60) }}</small>
                                        @endif
                                    </td>
                                    <td><code>{{ $plan->slug }}</code></td>
                                    <td>
                                        <span class="badge bg-secondary-subtle text-dark border">
                                            <i class="fa-regular fa-calendar-days me-1"></i> {{ $plan->duration_days }} يوماً
                                        </span>
                                    </td>
                                    <td>
                                        <span class="fw-bold fs-5 text-primary">{{ number_format($plan->price, 2) }}</span>
                                        <small class="text-muted fw-bold">{{ $plan->currency }}</small>
                                    </td>
                                    <td>
                                        <span class="badge bg-success-subtle text-success border border-success">
                                            <i class="fa-solid fa-user-check me-1"></i> {{ $plan->active_subscribers_count }} مشترك
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-secondary border">
                                            {{ $plan->orders_count }} طلب
                                        </span>
                                    </td>
                                    <td>
                                        <form action="{{ route('admin.plans.toggle', $plan->id) }}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn-sm {{ $plan->is_active ? 'btn-success' : 'btn-outline-secondary' }}" title="انقر لتغيير الحالة">
                                                <i class="fa-solid {{ $plan->is_active ? 'fa-check-circle' : 'fa-circle-xmark' }} me-1"></i>
                                                {{ $plan->is_active ? 'مفعلة' : 'معطلة' }}
                                            </button>
                                        </form>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <a href="{{ route('admin.plans.edit', $plan->id) }}" class="btn btn-sm btn-outline-primary" title="تعديل الباقة">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </a>
                                            <form action="{{ route('admin.plans.destroy', $plan->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من رغبتك في حذف هذه الباقة؟')">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="حذف" {{ $plan->orders_count > 0 ? 'disabled' : '' }}>
                                                    <i class="fa-solid fa-trash-can"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        لا توجد باقات مدخلة حالياً. اضغط على زر "إضافة باقة جديدة" بالأعلى.
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
