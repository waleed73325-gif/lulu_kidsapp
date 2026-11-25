@extends('admin.layout')

@section('title', 'مركز الإشعارات والتعميمات')
@section('page_title', 'مركز الإشعارات والتعميمات لأولياء الأمور')

@section('content')
<!-- إحصائيات سريعة -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="stat-card d-flex align-items-center justify-content-between">
            <div>
                <div class="text-muted small fw-bold">إجمالي الإشعارات</div>
                <div class="fs-4 fw-bolder mt-1">{{ number_format($stats['total']) }}</div>
            </div>
            <div class="stat-icon" style="background-color: rgba(108, 92, 231, 0.12); color: var(--lulu-primary);">
                <i class="fa-solid fa-bell"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card d-flex align-items-center justify-content-between">
            <div>
                <div class="text-muted small fw-bold">غير المقروءة</div>
                <div class="fs-4 fw-bolder mt-1 text-warning">{{ number_format($stats['unread']) }}</div>
            </div>
            <div class="stat-icon" style="background-color: rgba(253, 203, 110, 0.2); color: #e67e22;">
                <i class="fa-solid fa-envelope-open-text"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card d-flex align-items-center justify-content-between">
            <div>
                <div class="text-muted small fw-bold">المقروءة</div>
                <div class="fs-4 fw-bolder mt-1 text-success">{{ number_format($stats['read']) }}</div>
            </div>
            <div class="stat-icon" style="background-color: rgba(0, 184, 148, 0.12); color: var(--lulu-green);">
                <i class="fa-solid fa-circle-check"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="stat-card d-flex align-items-center justify-content-between">
            <div>
                <div class="text-muted small fw-bold">التعميمات والعروض</div>
                <div class="fs-4 fw-bolder mt-1 text-primary">{{ number_format($stats['broadcast']) }}</div>
            </div>
            <div class="stat-icon" style="background-color: rgba(9, 132, 227, 0.12); color: #0984e3;">
                <i class="fa-solid fa-bullhorn"></i>
            </div>
        </div>
    </div>
</div>

<div class="card table-custom border-0 shadow-sm mb-4">
    <div class="card-body p-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
            <!-- أزرار التصفية -->
            <ul class="nav nav-pills gap-2">
                <li class="nav-item">
                    <a class="nav-link {{ $type === 'all' ? 'active bg-primary' : 'bg-light text-dark' }}" href="{{ route('admin.notifications.index', ['type' => 'all']) }}">
                        الكل ({{ $stats['total'] }})
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ $type === 'announcement' ? 'active bg-primary' : 'bg-light text-dark' }}" href="{{ route('admin.notifications.index', ['type' => 'announcement']) }}">
                        تعميمات عامة 📢
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ $type === 'offer' ? 'active bg-warning text-dark fw-bold' : 'bg-light text-dark' }}" href="{{ route('admin.notifications.index', ['type' => 'offer']) }}">
                        عروض وتخفيضات 🎁
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ $type === 'subscription_approved' ? 'active bg-success' : 'bg-light text-success' }}" href="{{ route('admin.notifications.index', ['type' => 'subscription_approved']) }}">
                        اعتمادات الاشتراكات ✅
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link {{ $type === 'subscription_rejected' ? 'active bg-danger' : 'bg-light text-danger' }}" href="{{ route('admin.notifications.index', ['type' => 'subscription_rejected']) }}">
                        تنبيهات الرفض ⚠️
                    </a>
                </li>
            </ul>

            <!-- زر إرسال إشعار جديد -->
            <a href="{{ route('admin.notifications.create') }}" class="btn btn-lulu-primary d-flex align-items-center gap-2">
                <i class="fa-solid fa-paper-plane"></i>
                <span>إرسال تعميم / إشعار جديد</span>
            </a>
        </div>

        <!-- البحث -->
        <form method="GET" action="{{ route('admin.notifications.index') }}" class="row g-3 mb-4">
            <input type="hidden" name="type" value="{{ $type }}">
            <div class="col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" name="search" class="form-control border-start-0" placeholder="ابحث بعنوان الإشعار أو محتواه أو اسم ولي الأمر..." value="{{ request('search') }}">
                </div>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-outline-primary w-100">بحث</button>
            </div>
        </form>

        <!-- جدول الإشعارات -->
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th style="width: 50px;">#</th>
                        <th>ولي الأمر المستلم</th>
                        <th>العنوان والمحتوى</th>
                        <th>النوع</th>
                        <th>حالة القراءة</th>
                        <th>تاريخ الإرسال</th>
                        <th style="width: 80px;">إجراء</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($notifications as $notif)
                        <tr>
                            <td>{{ $notif->id }}</td>
                            <td>
                                @if($notif->user)
                                    <div class="fw-bold">{{ $notif->user->name }}</div>
                                    <small class="text-muted">{{ $notif->user->email }}</small>
                                @else
                                    <span class="badge bg-secondary">مستخدم غير متوفر</span>
                                @endif
                            </td>
                            <td>
                                <div class="fw-bold text-dark">{{ $notif->title }}</div>
                                <div class="text-muted small mt-1" style="max-width: 420px; white-space: normal; line-height: 1.4;">
                                    {{ Str::limit($notif->body, 120) }}
                                </div>
                            </td>
                            <td>
                                @switch($notif->type)
                                    @case('subscription_approved')
                                        <span class="badge bg-success-subtle text-success border border-success">اعتماد اشتراك ✅</span>
                                        @break
                                    @case('subscription_rejected')
                                        <span class="badge bg-danger-subtle text-danger border border-danger">رفض حوالة ❌</span>
                                        @break
                                    @case('announcement')
                                        <span class="badge bg-primary-subtle text-primary border border-primary">تعميم عام 📢</span>
                                        @break
                                    @case('offer')
                                        <span class="badge bg-warning-subtle text-dark border border-warning">عرض خاص 🎁</span>
                                        @break
                                    @case('update')
                                        <span class="badge bg-info-subtle text-info border border-info">تحديث نظام ✨</span>
                                        @break
                                    @case('alert')
                                        <span class="badge bg-danger-subtle text-danger border border-danger">تنبيه هـام ⚠️</span>
                                        @break
                                    @default
                                        <span class="badge bg-secondary-subtle text-secondary border">إشعار عام 🔔</span>
                                @endswitch
                            </td>
                            <td>
                                @if($notif->is_read)
                                    <span class="badge bg-success-subtle text-success">
                                        <i class="fa-solid fa-check-double me-1"></i> مقروء
                                    </span>
                                    @if($notif->read_at)
                                        <div class="text-muted small" style="font-size: 11px;">{{ $notif->read_at->format('Y-m-d H:i') }}</div>
                                    @endif
                                @else
                                    <span class="badge bg-warning-subtle text-dark">
                                        <i class="fa-regular fa-clock me-1"></i> غير مقروء
                                    </span>
                                @endif
                            </td>
                            <td>
                                <small class="text-muted">{{ $notif->created_at->format('Y-m-d H:i') }}</small>
                            </td>
                            <td>
                                <form action="{{ route('admin.notifications.destroy', $notif->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من رغبتك في حذف هذا الإشعار؟');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="حذف">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="text-center py-5 text-muted">
                                <i class="fa-regular fa-bell-slash fs-1 d-block mb-3 text-secondary"></i>
                                لا توجد إشعارات مسجلة حالياً ضمن التصفية المحددة.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="mt-4">
            {{ $notifications->links() }}
        </div>
    </div>
</div>
@endsection
