@extends('admin.layout')

@section('title', 'مراجعة التحويلات المالية والاشتراكات')
@section('page_title', 'مراجعة طلبات الدفع اليدوي وتفعيل الاشتراكات')

@section('content')
<div class="card table-custom border-0 shadow-sm mb-4">
    <div class="card-body p-4">
        <!-- تابات التصفية -->
        <ul class="nav nav-pills mb-4 gap-2">
            <li class="nav-item">
                <a class="nav-link {{ $status === 'all' ? 'active bg-primary' : 'bg-light text-dark' }}" href="{{ route('admin.payments.index', ['status' => 'all']) }}">
                    الكل ({{ $counts['all'] }})
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ $status === 'pending' ? 'active bg-danger' : 'bg-light text-danger' }} fw-bold" href="{{ route('admin.payments.index', ['status' => 'pending']) }}">
                    قيد المراجعة ({{ $counts['pending'] }}) ⏳
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ $status === 'verified' ? 'active bg-success' : 'bg-light text-success' }}" href="{{ route('admin.payments.index', ['status' => 'verified']) }}">
                    المعتمدة والمفعلة ({{ $counts['verified'] }}) ✅
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link {{ $status === 'rejected' ? 'active bg-secondary' : 'bg-light text-muted' }}" href="{{ route('admin.payments.index', ['status' => 'rejected']) }}">
                    المرفوضة ({{ $counts['rejected'] }})
                </a>
            </li>
        </ul>

        <!-- جدول الحوالات والمدفوعات -->
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th>رقم الطلب</th>
                        <th>ولي الأمر</th>
                        <th>الباقة المختارة</th>
                        <th>المبلغ المطلوب</th>
                        <th>رقم مرجع التحويل</th>
                        <th>الحالة</th>
                        <th>تاريخ الطلب</th>
                        <th style="width: 170px;">الإجراء والاعتماد</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($payments as $payment)
                        <tr>
                            <td><code>#ORD-{{ $payment->order_id }}</code></td>
                            <td>
                                <div class="fw-bold">{{ $payment->order->user->name ?? 'مستخدم محذوف' }}</div>
                                <small class="text-muted">{{ $payment->order->user->email ?? '' }} | {{ $payment->order->user->phone ?? '' }}</small>
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border">{{ $payment->order->plan->name ?? 'باقة مخصصة' }}</span>
                            </td>
                            <td>
                                <span class="fw-bold text-success fs-6">{{ $payment->order->amount }} {{ $payment->order->currency }}</span>
                            </td>
                            <td>
                                @if($payment->transfer_reference)
                                    <code class="fs-6">{{ $payment->transfer_reference }}</code>
                                @else
                                    <span class="text-muted small">لم يرفق مرجعاً</span>
                                @endif

                                @if($payment->proof_path)
                                    <div class="mt-2 d-flex align-items-center gap-2">
                                        <button type="button" class="btn p-0 border-0 bg-transparent" data-bs-toggle="modal" data-bs-target="#proofModal{{ $payment->id }}" title="انقر لتكبير الإيصال">
                                            <img src="{{ url('storage/' . $payment->proof_path) }}" 
                                                 alt="إيصال التحويل" 
                                                 class="rounded border shadow-sm" 
                                                 style="width: 48px; height: 48px; object-fit: cover; cursor: pointer; transition: transform 0.2s;"
                                                 onmouseover="this.style.transform='scale(1.08)'"
                                                 onmouseout="this.style.transform='scale(1)'"
                                                 onerror="this.onerror=null; this.src='https://placehold.co/100x100/f1f5f9/64748b?text=إيصال';">
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-primary fw-bold" data-bs-toggle="modal" data-bs-target="#proofModal{{ $payment->id }}">
                                            <i class="fa-solid fa-eye me-1"></i> عرض الإيصال
                                        </button>
                                    </div>

                                    <!-- نافذة استعراض إيصال التحويل بالحجم الكامل -->
                                    <div class="modal fade" id="proofModal{{ $payment->id }}" tabindex="-1" aria-labelledby="proofModalLabel{{ $payment->id }}" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered modal-lg">
                                            <div class="modal-content rounded-4 border-0 shadow-lg">
                                                <div class="modal-header border-bottom bg-light">
                                                    <h6 class="modal-title fw-bold" id="proofModalLabel{{ $payment->id }}">
                                                        <i class="fa-solid fa-receipt text-primary me-2"></i>
                                                        إيصال التحويل للطلب: #ORD-{{ $payment->order_id }} ({{ $payment->order->user->name ?? 'ولي الأمر' }})
                                                    </h6>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                </div>
                                                <div class="modal-body text-center p-3 bg-dark-subtle rounded-bottom">
                                                    <div class="mb-2 text-muted small">
                                                        <span>رقم المرجع: <code>{{ $payment->transfer_reference ?? 'غير محدد' }}</code></span> |
                                                        <span>المبلغ: <strong class="text-success">{{ $payment->order->amount }} {{ $payment->order->currency }}</strong></span>
                                                    </div>
                                                    <div class="d-flex justify-content-center align-items-center" style="min-height: 250px;">
                                                        <img src="{{ url('storage/' . $payment->proof_path) }}" 
                                                             alt="إيصال التحويل #ORD-{{ $payment->order_id }}" 
                                                             class="img-fluid rounded-3 shadow border" 
                                                             style="max-height: 70vh; object-fit: contain;"
                                                             onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'alert alert-warning mb-0\'><i class=\'fa-solid fa-triangle-exclamation me-2\'></i>تعذر تحميل صورة الإيصال أو انتهت صلاحية الرابط</div>';">
                                                    </div>
                                                </div>
                                                <div class="modal-footer bg-light border-top d-flex justify-content-between">
                                                    <a href="{{ url('storage/' . $payment->proof_path) }}" target="_blank" class="btn btn-outline-secondary btn-sm">
                                                        <i class="fa-solid fa-arrow-up-right-from-square me-1"></i> فتح في نافذة مستقلة
                                                    </a>
                                                    <button type="button" class="btn btn-primary btn-sm px-4" data-bs-dismiss="modal">إغلاق</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                @else
                                    <div class="mt-1 small text-muted">
                                        <i class="fa-regular fa-image me-1"></i> لم ترفق صورة
                                    </div>
                                @endif
                            </td>
                            <td>
                                @if($payment->status === 'verified')
                                    <span class="badge badge-verified"><i class="fa-solid fa-check-circle me-1"></i> معتمد ومفعل</span>
                                    @if($payment->order && $payment->order->subscription && ($payment->order->subscription->status === 'revoked' || $payment->order->subscription->cancelled_by === 'parent'))
                                        <div class="mt-1">
                                            <span class="badge bg-danger-subtle text-danger border border-danger p-1" style="font-size: 11px;" title="{{ $payment->order->subscription->cancellation_reason ?? 'تم الإلغاء من قبل ولي الأمر' }}">
                                                <i class="fa-solid fa-ban me-1"></i> أُلغي من قِبل ولي الأمر
                                            </span>
                                        </div>
                                    @endif
                                @elseif($payment->status === 'pending')
                                    <span class="badge badge-pending"><i class="fa-solid fa-clock me-1"></i> قيد المراجعة</span>
                                @else
                                    <span class="badge bg-secondary-subtle text-danger" title="{{ $payment->rejection_reason }}">
                                        <i class="fa-solid fa-circle-xmark me-1"></i> مرفوض
                                    </span>
                                @endif
                            </td>
                            <td>
                                <small class="text-muted">{{ $payment->created_at->format('Y-m-d H:i') }}</small>
                            </td>
                            <td>
                                @if($payment->status === 'pending')
                                    <div class="d-flex align-items-center gap-1">
                                        <!-- زر الاعتماد الفوري -->
                                        <form action="{{ route('admin.payments.approve', $payment->id) }}" method="POST" class="d-inline" onsubmit="return confirm('هل تأكدت من وصول المبلغ البنكي وتفعيل اشتراك المستخدم؟')">
                                            @csrf
                                            <button type="submit" class="btn btn-sm btn-success px-3" title="اعتماد وتفعيل الاشتراك">
                                                <i class="fa-solid fa-check me-1"></i> تفعيل
                                            </button>
                                        </form>

                                        <!-- زر الرفض -->
                                        <button type="button" class="btn btn-sm btn-outline-danger" data-bs-toggle="modal" data-bs-target="#rejectModal{{ $payment->id }}" title="رفض الحوالة">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </div>

                                    <!-- نافذة الرفض -->
                                    <div class="modal fade" id="rejectModal{{ $payment->id }}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content rounded-4 border-0">
                                                <form action="{{ route('admin.payments.reject', $payment->id) }}" method="POST">
                                                    @csrf
                                                    <div class="modal-header">
                                                        <h6 class="modal-title fw-bold">رفض إثبات التحويل #ORD-{{ $payment->order_id }}</h6>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold small">سبب الرفض (سيظهر لولي الأمر في التطبيق):</label>
                                                            <textarea name="rejection_reason" class="form-control" rows="3" required placeholder="مثال: رقم المرجع غير متطابق مع كشف الحساب البنكي، أو لم يصل المبلغ."></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">إلغاء</button>
                                                        <button type="submit" class="btn btn-danger">تأكيد الرفض</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                @else
                                    <span class="text-muted small">مكتمل</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="fa-solid fa-inbox fs-1 mb-3 text-secondary"></i>
                                <div>لا توجد طلبات حوالات في هذه القائمة حالياً.</div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $payments->links() }}
        </div>
    </div>
</div>
@endsection
