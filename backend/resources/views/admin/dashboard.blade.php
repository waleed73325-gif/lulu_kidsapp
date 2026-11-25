@extends('admin.layout')

@section('title', 'لوحة المؤشرات الرئيسية')
@section('page_title', 'نظرة عامة على النظام والمحتوى')

@section('content')
<div class="row g-4 mb-4">
    <!-- كرت الدروس -->
    <div class="col-md-3">
        <div class="stat-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <span class="text-muted fw-bold small">إجمالي الدروس والأنشطة</span>
                <div class="stat-icon" style="background: rgba(108, 92, 231, 0.12); color: #6C5CE7;">
                    <i class="fa-solid fa-book-open"></i>
                </div>
            </div>
            <h3 class="fw-bold mb-1">{{ $stats['total_lessons'] }}</h3>
            <span class="badge badge-free">موزعة على {{ $stats['total_categories'] }} جزر</span>
        </div>
    </div>

    <!-- كرت الجزر التعليمية -->
    <div class="col-md-3">
        <div class="stat-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <span class="text-muted fw-bold small">جزر المحتوى (التصنيفات)</span>
                <div class="stat-icon" style="background: rgba(0, 184, 148, 0.12); color: #00B894;">
                    <i class="fa-solid fa-map-location-dot"></i>
                </div>
            </div>
            <h3 class="fw-bold mb-1">{{ $stats['total_categories'] }}</h3>
            <span class="text-muted small">حروف، أرقام، ألوان، قصص...</span>
        </div>
    </div>

    <!-- كرت أولياء الأمور والأطفال -->
    <div class="col-md-3">
        <div class="stat-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <span class="text-muted fw-bold small">أولياء الأمور والأطفال</span>
                <div class="stat-icon" style="background: rgba(253, 121, 168, 0.15); color: #FD79A8;">
                    <i class="fa-solid fa-children"></i>
                </div>
            </div>
            <h3 class="fw-bold mb-1">{{ $stats['total_parents'] }} <small class="fs-6 text-muted fw-normal">({{ $stats['total_children'] }} طفل)</small></h3>
            <span class="text-muted small">حسابات عائلية مسجلة</span>
        </div>
    </div>

    <!-- كرت الحوالات المعلقة -->
    <div class="col-md-3">
        <div class="stat-card">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <span class="text-muted fw-bold small">تحويلات بانتظار المراجعة</span>
                <div class="stat-icon" style="background: rgba(255, 118, 117, 0.15); color: #FF7675;">
                    <i class="fa-solid fa-clock"></i>
                </div>
            </div>
            <h3 class="fw-bold mb-1 text-danger">{{ $stats['pending_payments'] }}</h3>
            <div class="d-flex justify-content-between align-items-center">
                <a href="{{ route('admin.payments.index', ['status' => 'pending']) }}" class="small text-decoration-none fw-bold">
                    مراجعة واعتماد <i class="fa-solid fa-arrow-left"></i>
                </a>
                <span class="badge bg-danger-subtle text-danger border border-danger">{{ $stats['cancelled_subscriptions'] }} اشتراك ملغي</span>
            </div>
        </div>
    </div>
</div>

<!-- اشتراكات ملغاة حديثاً من قبل أولياء الأمور إن وجدت -->
@if($recentCancelledSubscriptions->isNotEmpty())
<div class="row g-4 mb-4">
    <div class="col-12">
        <div class="stat-card border border-danger-subtle shadow-sm">
            <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom">
                <h6 class="fw-bold m-0 text-danger">
                    <i class="fa-solid fa-user-xmark me-2"></i>تنبيه: اشتراكات قام أولياء الأمور بإلغائها حديثاً من التطبيق
                </h6>
                <span class="badge bg-danger">{{ $stats['cancelled_subscriptions'] }} إجمالي الملغي</span>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr class="small text-muted">
                            <th>ولي الأمر</th>
                            <th>البريد الإلكتروني</th>
                            <th>تاريخ الإلغاء</th>
                            <th>السبب والملاحظات</th>
                            <th>الحالة في النظام</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($recentCancelledSubscriptions as $sub)
                            <tr>
                                <td>
                                    <div class="fw-bold">{{ $sub->user->name ?? 'غير معروف' }}</div>
                                </td>
                                <td>
                                    <code>{{ $sub->user->email ?? '-' }}</code>
                                </td>
                                <td>
                                    <span class="small fw-bold text-danger">
                                        <i class="fa-regular fa-clock me-1"></i>{{ $sub->cancelled_at ? $sub->cancelled_at->format('Y-m-d H:i') : $sub->updated_at->format('Y-m-d H:i') }}
                                    </span>
                                </td>
                                <td>
                                    <small class="text-muted">{{ $sub->cancellation_reason ?? 'تم إلغاء الاشتراك من قبل ولي الأمر عبر التطبيق' }}</small>
                                </td>
                                <td>
                                    <span class="badge bg-danger-subtle text-danger border border-danger">
                                        <i class="fa-solid fa-ban me-1"></i> ملغي بواسطة ولي الأمر
                                    </span>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endif

<!-- إجراءات سريعة وقسم الحوالات الأخيرة -->
<div class="row g-4">
    <!-- قائمة التحويلات المعلقة -->
    <div class="col-lg-6">
        <div class="stat-card h-100">
            <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom">
                <h6 class="fw-bold m-0"><i class="fa-solid fa-money-bill-transfer text-primary me-2"></i>طلبات التحويل اليدوي الحديثة</h6>
                <a href="{{ route('admin.payments.index') }}" class="btn btn-sm btn-outline-primary">عرض الكل</a>
            </div>

            @if($recentPendingPayments->isEmpty())
                <div class="text-center py-4 text-muted">
                    <i class="fa-regular fa-circle-check fs-1 text-success mb-2"></i>
                    <div>لا توجد حوالات معلقة بانتظار المراجعة حالياً! ✨</div>
                </div>
            @else
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="small text-muted">
                                <th>ولي الأمر</th>
                                <th>الباقة</th>
                                <th>المبلغ</th>
                                <th>الإجراء</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($recentPendingPayments as $payment)
                                <tr>
                                    <td>
                                        <div class="fw-bold">{{ $payment->order->user->name ?? 'غير معروف' }}</div>
                                        <small class="text-muted">{{ $payment->transfer_reference ?? 'بدون مرجع' }}</small>
                                    </td>
                                    <td>{{ $payment->order->plan->name ?? '-' }}</td>
                                    <td class="fw-bold text-success">{{ $payment->order->amount }} {{ $payment->order->currency }}</td>
                                    <td>
                                        <form action="{{ route('admin.payments.approve', $payment->id) }}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="btn btn-sm btn-success py-1 px-2" title="تفعيل الاشتراك فوري" onclick="return confirm('تأكيد استلام المبلغ وتفعيل الاشتراك؟')">
                                                <i class="fa-solid fa-check"></i> تفعيل
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif
        </div>
    </div>

    <!-- أحدث الدروس المضافة -->
    <div class="col-lg-6">
        <div class="stat-card h-100">
            <div class="d-flex align-items-center justify-content-between mb-3 pb-2 border-bottom">
                <h6 class="fw-bold m-0"><i class="fa-solid fa-shapes text-warning me-2"></i>أحدث الدروس في النظام</h6>
                <a href="{{ route('admin.lessons.index') }}" class="btn btn-sm btn-outline-primary">إدارة الدروس</a>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr class="small text-muted">
                            <th>الدرس</th>
                            <th>الجزيرة</th>
                            <th>المستوى</th>
                            <th>الإجراء</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($recentLessons as $lesson)
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fs-5">{{ $lesson->content_arabic }}</span>
                                        <div>
                                            <div class="fw-bold">{{ $lesson->title }}</div>
                                            <small class="text-muted">{{ $lesson->example_word }}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge bg-light text-dark">{{ $lesson->category->name_ar ?? '-' }}</span>
                                </td>
                                <td>
                                    @if($lesson->access_level === 'free')
                                        <span class="badge badge-free">مجاني</span>
                                    @else
                                        <span class="badge badge-premium">بلس ⭐</span>
                                    @endif
                                </td>
                                <td>
                                    <a href="{{ route('admin.lessons.edit', $lesson->id) }}" class="btn btn-sm btn-outline-secondary py-1 px-2" title="تعديل">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection
