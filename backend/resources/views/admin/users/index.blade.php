@extends('admin.layout')

@section('title', 'أولياء الأمور والأطفال')
@section('page_title', 'قائمة أولياء الأمور وملفات الأطفال المسجلين')

@section('content')
<div class="card table-custom border-0 shadow-sm mb-4">
    <div class="card-body p-4">
        <!-- البحث -->
        <form method="GET" action="{{ route('admin.users.index') }}" class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" name="search" class="form-control border-start-0" placeholder="ابحث باسم ولي الأمر، البريد، أو الهاتف..." value="{{ request('search') }}">
                </div>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-lulu-primary w-100">بحث</button>
            </div>
        </form>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th>ولي الأمر</th>
                        <th>معلومات الاتصال</th>
                        <th>ملفات الأطفال المسجلة</th>
                        <th>حالة الاشتراك</th>
                        <th>تاريخ التسجيل</th>
                        <th style="width: 140px;">الإجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($parents as $parent)
                        <tr>
                            <td>
                                <div class="fw-bold">{{ $parent->name }}</div>
                                <span class="badge bg-light text-dark">مستخدم عائلي</span>
                            </td>
                            <td>
                                <div><i class="fa-regular fa-envelope me-1 text-muted"></i> {{ $parent->email }}</div>
                                @if($parent->phone)
                                    <div><i class="fa-solid fa-phone me-1 text-muted"></i> {{ $parent->phone }}</div>
                                @endif
                            </td>
                            <td>
                                @if($parent->children->isEmpty())
                                    <span class="text-muted small">لم يضف أطفالاً بعد</span>
                                @else
                                    <div class="d-flex flex-wrap gap-1">
                                        @foreach($parent->children as $child)
                                            <span class="badge bg-primary-subtle text-primary border">
                                                🐰 {{ $child->nickname }} ({{ $child->birth_year }}) - <span class="text-warning fw-bold">⭐ {{ $child->stars_count ?? 12 }}</span>
                                            </span>
                                        @endforeach
                                    </div>
                                @endif
                            </td>
                            <td>
                                @php
                                    $latestSub = $parent->latestSubscription();
                                @endphp
                                @if($parent->hasActiveSubscription())
                                    <span class="badge badge-verified">
                                        <i class="fa-solid fa-crown me-1"></i> بلس نشط (ينتهي {{ $parent->activeSubscription()->ends_at->format('Y-m-d') }})
                                    </span>
                                @elseif($latestSub && ($latestSub->cancelled_by === 'parent' || $latestSub->status === 'revoked'))
                                    <div>
                                        <span class="badge bg-danger-subtle text-danger border border-danger p-1">
                                            <i class="fa-solid fa-ban me-1"></i> ملغي من قِبل ولي الأمر
                                        </span>
                                        @if($latestSub->cancelled_at)
                                            <div class="small text-danger mt-1 fw-bold" style="font-size: 11px;">
                                                <i class="fa-regular fa-clock me-1"></i> {{ $latestSub->cancelled_at->format('Y-m-d H:i') }}
                                            </div>
                                        @endif
                                    </div>
                                @elseif($latestSub && $latestSub->status === 'expired')
                                    <span class="badge bg-warning-subtle text-dark border border-warning">
                                        <i class="fa-solid fa-clock-rotate-left me-1"></i> اشتراك منتهي
                                    </span>
                                @else
                                    <span class="badge bg-secondary-subtle text-muted">مجاني (غير مشترك)</span>
                                @endif
                            </td>
                            <td>
                                <small class="text-muted">{{ $parent->created_at->format('Y-m-d') }}</small>
                            </td>
                            <td>
                                <div class="d-flex gap-1">
                                    <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#parentDetailModal{{ $parent->id }}" title="عرض التفاصيل الكاملة">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                    <a href="{{ route('admin.notifications.create', ['user_id' => $parent->id]) }}" class="btn btn-sm btn-outline-warning text-dark" title="إرسال إشعار مباشر لولي الأمر">
                                        <i class="fa-solid fa-paper-plane"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>

                        <!-- نافذة تفاصيل ولي الأمر والملفات -->
                        <div class="modal fade" id="parentDetailModal{{ $parent->id }}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-lg modal-dialog-centered">
                                <div class="modal-content border-0 rounded-4 shadow">
                                    <div class="modal-header bg-light">
                                        <h5 class="modal-title fw-bold text-primary">
                                            <i class="fa-solid fa-user-circle me-1"></i> ملف ولي الأمر: {{ $parent->name }}
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="إغلاق"></button>
                                    </div>
                                    <div class="modal-body p-4">
                                        <!-- بيانات الحساب -->
                                        <div class="row g-3 mb-4 pb-3 border-bottom">
                                            <div class="col-md-4">
                                                <div class="text-muted small">البريد الإلكتروني</div>
                                                <div class="fw-bold">{{ $parent->email }}</div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="text-muted small">رقم الهاتف</div>
                                                <div class="fw-bold">{{ $parent->phone ?? 'غير مسجل' }}</div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="text-muted small">تاريخ الانضمام</div>
                                                <div class="fw-bold">{{ $parent->created_at->format('Y-m-d H:i') }}</div>
                                            </div>
                                        </div>

                                        <!-- ملفات الأطفال وإنجازاتهم -->
                                        <h6 class="fw-bold text-dark mb-3">
                                            <i class="fa-solid fa-children text-primary me-1"></i> ملفات الأطفال المسجلة ({{ $parent->children->count() }})
                                        </h6>
                                        <div class="row g-3 mb-4 pb-3 border-bottom">
                                            @forelse($parent->children as $child)
                                                <div class="col-md-6">
                                                    <div class="p-3 bg-light rounded-3 border">
                                                        <div class="d-flex align-items-center justify-content-between mb-2">
                                                            <div class="fw-bold fs-6 text-primary">🐰 {{ $child->nickname }}</div>
                                                            <span class="badge bg-secondary-subtle text-dark">مواليد {{ $child->birth_year }}</span>
                                                        </div>
                                                        <div class="d-flex align-items-center justify-content-between small">
                                                            <div>
                                                                النجوم المجمّعة: <span class="fw-bold text-warning">⭐ {{ $child->stars_count ?? 12 }}</span>
                                                            </div>
                                                            <div>
                                                                الدروس المتقنة: <span class="fw-bold text-success">📚 {{ count($child->completed_lessons ?? []) }}</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            @empty
                                                <div class="col-12 text-muted small py-2">لا يوجد أطفال مضافون في هذا الحساب حالياً.</div>
                                            @endforelse
                                        </div>

                                        <!-- سجل الاشتراكات والمدفوعات -->
                                        <h6 class="fw-bold text-dark mb-3">
                                            <i class="fa-solid fa-receipt text-primary me-1"></i> سجل الطلبات والتحويلات المالية
                                        </h6>
                                        @if($parent->orders->isEmpty())
                                            <div class="text-muted small">لا توجد طلبات أو تحويلات سابقة لهذا المستخدم.</div>
                                        @else
                                            <div class="table-responsive">
                                                <table class="table table-sm table-bordered align-middle mb-0">
                                                    <thead class="table-light">
                                                        <tr>
                                                            <th>رقم الطلب</th>
                                                            <th>الباقة</th>
                                                            <th>المبلغ</th>
                                                            <th>حالة الدفع</th>
                                                            <th>تاريخ الطلب</th>
                                                            <th>الإيصال</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        @foreach($parent->orders as $order)
                                                            <tr>
                                                                <td>#ORD-{{ $order->id }}</td>
                                                                <td>{{ $order->plan->name ?? 'باقة اشتراك' }}</td>
                                                                <td>{{ $order->amount }} {{ $order->currency }}</td>
                                                                <td>
                                                                    @if($order->status === 'verified')
                                                                        <span class="badge bg-success">معتمد ومفعل</span>
                                                                    @elseif($order->status === 'rejected')
                                                                        <span class="badge bg-danger">مرفوض</span>
                                                                    @else
                                                                        <span class="badge bg-warning text-dark">قيد المراجعة</span>
                                                                    @endif
                                                                </td>
                                                                <td>{{ $order->created_at->format('Y-m-d') }}</td>
                                                                <td>
                                                                    @if($order->payment && $order->payment->proof_path)
                                                                        <a href="{{ url('storage/' . $order->payment->proof_path) }}" target="_blank" class="btn btn-xs btn-outline-primary" style="font-size: 11px; padding: 2px 6px;">
                                                                            <i class="fa-solid fa-image me-1"></i> فتح الإيصال
                                                                        </a>
                                                                    @else
                                                                        <span class="text-muted small">-</span>
                                                                    @endif
                                                                </td>
                                                            </tr>
                                                        @endforeach
                                                    </tbody>
                                                </table>
                                            </div>
                                        @endif
                                    </div>
                                    <div class="modal-footer bg-light">
                                        <a href="{{ route('admin.notifications.create', ['user_id' => $parent->id]) }}" class="btn btn-primary btn-sm">
                                            <i class="fa-solid fa-paper-plane me-1"></i> إرسال إشعار مباشر لهذا الحساب
                                        </a>
                                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">إغلاق</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @empty
                        <tr>
                            <td colspan="6" class="text-center py-5 text-muted">
                                <div>لا يوجد أولياء أمور مسجلون حالياً.</div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $parents->links() }}
        </div>
    </div>
</div>
@endsection
