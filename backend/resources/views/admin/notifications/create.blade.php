@extends('admin.layout')

@section('title', 'إرسال إشعار أو تعميم جديد')
@section('page_title', 'إرسال إشعار أو تعميم جديد لأولياء الأمور')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4 p-md-5">
                <div class="d-flex align-items-center justify-content-between mb-4 border-bottom pb-3">
                    <div>
                        <h4 class="fw-bold mb-1 text-primary">📢 إرسال إشعار فوري</h4>
                        <p class="text-muted small mb-0">يمكنك بث تعميم لكافة أولياء الأمور أو فئة محددة أو مستخدم بعينه ليظهر فورياً في تطبيق لولو.</p>
                    </div>
                    <a href="{{ route('admin.notifications.index') }}" class="btn btn-outline-secondary btn-sm">
                        <i class="fa-solid fa-arrow-right me-1"></i> العودة للقائمة
                    </a>
                </div>

                <form action="{{ route('admin.notifications.send') }}" method="POST">
                    @csrf

                    <!-- الفئة المستهدفة -->
                    <div class="mb-4">
                        <label class="form-label fw-bold">الفئة المستهدفة بالإشعار <span class="text-danger">*</span></label>
                        <div class="row g-2">
                            <div class="col-md-6">
                                <div class="form-check p-3 border rounded-3 bg-light">
                                    <input class="form-check-input ms-2" type="radio" name="target" id="targetAll" value="all" checked onchange="toggleTargetUser(this.value)">
                                    <label class="form-check-label fw-bold" for="targetAll">
                                        👨‍👩‍👧‍👦 جميع أولياء الأمور المسجلين
                                    </label>
                                    <div class="text-muted small mt-1 ms-4">إرسال تعميم جماعي لكل الحسابات</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check p-3 border rounded-3 bg-light">
                                    <input class="form-check-input ms-2" type="radio" name="target" id="targetActive" value="active_subscribers" onchange="toggleTargetUser(this.value)">
                                    <label class="form-check-label fw-bold" for="targetActive">
                                        ⭐ المشتركون الفعّالون (Lulu+)
                                    </label>
                                    <div class="text-muted small mt-1 ms-4">تحديثات أو رسائل خاصة بالمشتركين</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check p-3 border rounded-3 bg-light">
                                    <input class="form-check-input ms-2" type="radio" name="target" id="targetFree" value="free_parents" onchange="toggleTargetUser(this.value)">
                                    <label class="form-check-label fw-bold" for="targetFree">
                                        🎁 أصحاب الحسابات المجانية
                                    </label>
                                    <div class="text-muted small mt-1 ms-4">عروض الاشتراك والتخفيضات التشجيعية</div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check p-3 border rounded-3 bg-light">
                                    <input class="form-check-input ms-2" type="radio" name="target" id="targetSpecific" value="specific_user" {{ $selectedUserId ? 'checked' : '' }} onchange="toggleTargetUser(this.value)">
                                    <label class="form-check-label fw-bold" for="targetSpecific">
                                        👤 ولي أمر محدد بالاسم
                                    </label>
                                    <div class="text-muted small mt-1 ms-4">رسالة فردية موجهة لحساب معين</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- قائمة اختيار المستخدم في حال تم تحديد ولي أمر محدد -->
                    <div class="mb-4 {{ $selectedUserId ? '' : 'd-none' }}" id="userSelectContainer">
                        <label for="user_id" class="form-label fw-bold">اختر ولي الأمر <span class="text-danger">*</span></label>
                        <select name="user_id" id="user_id" class="form-select select2">
                            <option value="">-- ابحث بالاسم أو البريد --</option>
                            @foreach($parents as $parent)
                                <option value="{{ $parent->id }}" {{ (string)$selectedUserId === (string)$parent->id ? 'selected' : '' }}>
                                    {{ $parent->name }} ({{ $parent->email }}) {{ $parent->phone ? '- ' . $parent->phone : '' }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <!-- نوع الإشعار -->
                    <div class="mb-3">
                        <label for="type" class="form-label fw-bold">نوع الإشعار <span class="text-danger">*</span></label>
                        <select name="type" id="type" class="form-select" required>
                            <option value="announcement">📢 تعميم عام (إعلان لمحتوى جديد أو مناسبة)</option>
                            <option value="offer">🎁 عرض ترويجي / تخفيض اشتراك</option>
                            <option value="update">✨ تحديث في التطبيق أو ميزة جديدة</option>
                            <option value="alert">⚠️ تنبيه هام / صيانة مجدولة</option>
                            <option value="general">🔔 إشعار نظام عادي</option>
                        </select>
                    </div>

                    <!-- عنوان الإشعار -->
                    <div class="mb-3">
                        <label for="title" class="form-label fw-bold">عنوان الإشعار <span class="text-danger">*</span></label>
                        <input type="text" name="title" id="title" class="form-control" placeholder="مثال: خصم 30% بمناسبة نهاية الأسبوع! 🎉" value="{{ old('title') }}" required maxlength="150">
                        <div class="form-text">اجعل العنوان جذاباً وقصيراً ليظهر بوضوح على شاشات الجوال.</div>
                    </div>

                    <!-- نص الإشعار -->
                    <div class="mb-4">
                        <label for="body" class="form-label fw-bold">نص الإشعار والتفاصيل <span class="text-danger">*</span></label>
                        <textarea name="body" id="body" rows="4" class="form-control" placeholder="اكتب نص الرسالة التي ستصل لأولياء الأمور..." required maxlength="1000">{{ old('body') }}</textarea>
                    </div>

                    <div class="d-flex justify-content-end gap-2 border-top pt-3">
                        <a href="{{ route('admin.notifications.index') }}" class="btn btn-light px-4">إلغاء</a>
                        <button type="submit" class="btn btn-lulu-primary px-5 fw-bold">
                            <i class="fa-solid fa-paper-plane me-1"></i> إرسال الإشعار الآن
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleTargetUser(val) {
        const container = document.getElementById('userSelectContainer');
        const userSelect = document.getElementById('user_id');
        if (val === 'specific_user') {
            container.classList.remove('d-none');
            userSelect.setAttribute('required', 'required');
        } else {
            container.classList.add('d-none');
            userSelect.removeAttribute('required');
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const targetSpecific = document.getElementById('targetSpecific');
        if (targetSpecific && targetSpecific.checked) {
            toggleTargetUser('specific_user');
        }
    });
</script>
@endsection
