@extends('admin.layout')

@section('title', 'إدارة الدروس والأنشطة')
@section('page_title', 'قائمة الدروس والأنشطة التعليمية')

@section('content')
<div class="card table-custom border-0 shadow-sm mb-4">
    <div class="card-body p-4">
        <!-- شريط التصفية والبحث -->
        <form method="GET" action="{{ route('admin.lessons.index') }}" class="row g-3 mb-4 align-items-center">
            <div class="col-md-4">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" name="search" class="form-control border-start-0" placeholder="ابحث باسم الدرس، الحرف، أو الكلمة..." value="{{ request('search') }}">
                </div>
            </div>

            <div class="col-md-3">
                <select name="category_id" class="form-select" onchange="this.form.submit()">
                    <option value="">جميع الجزر والتصنيفات</option>
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}" {{ request('category_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name_ar }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div class="col-md-3">
                <select name="access_level" class="form-select" onchange="this.form.submit()">
                    <option value="">كل المستويات (مجاني ومدفوع)</option>
                    <option value="free" {{ request('access_level') == 'free' ? 'selected' : '' }}>دروس مجانية فقط</option>
                    <option value="premium" {{ request('access_level') == 'premium' ? 'selected' : '' }}>دروس باقة بلس (مدفوعة)</option>
                </select>
            </div>

            <div class="col-md-2 text-start">
                <a href="{{ route('admin.lessons.create') }}" class="btn btn-lulu-primary w-100">
                    <i class="fa-solid fa-plus me-1"></i> درس جديد
                </a>
            </div>
        </form>

        <!-- جدول الدروس -->
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th style="width: 60px;">الرمز</th>
                        <th>عنوان الدرس</th>
                        <th>الجزيرة / التصنيف</th>
                        <th>المثال والكلمة</th>
                        <th>مستوى الوصول</th>
                        <th>النجوم</th>
                        <th>الترتيب</th>
                        <th>الحالة</th>
                        <th style="width: 140px;">العمليات</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($lessons as $lesson)
                        <tr>
                            <td>
                                <div class="rounded-3 d-flex align-items-center justify-content-center fw-bold shadow-sm"
                                     style="width: 44px; height: 44px; background-color: {{ $lesson->primary_color }}22; color: {{ $lesson->primary_color }}; font-size: 20px;">
                                    {{ $lesson->content_arabic }}
                                </div>
                            </td>
                            <td>
                                <div class="fw-bold d-flex align-items-center gap-2">
                                    <span>{{ $lesson->title }}</span>
                                    @if($lesson->audio_path)
                                        <span class="badge bg-primary-subtle text-primary rounded-pill px-2 py-1" title="يوجد مقطع صوتي مرفوع لهذا الدرس">
                                            <i class="fa-solid fa-volume-high"></i> صوت مخصص
                                        </span>
                                    @endif
                                </div>
                                <small class="text-muted">{{ $lesson->subtitle }}</small>
                            </td>
                            <td>
                                <span class="badge bg-light text-dark border">{{ $lesson->category->name_ar ?? '-' }}</span>
                            </td>
                            <td>
                                <span class="fw-semibold">{{ $lesson->example_word ?? '-' }}</span>
                            </td>
                            <td>
                                @if($lesson->access_level === 'free')
                                    <span class="badge badge-free"><i class="fa-solid fa-gift me-1"></i> مجاني</span>
                                @else
                                    <span class="badge badge-premium"><i class="fa-solid fa-lock me-1"></i> لولو بلس ⭐</span>
                                @endif
                            </td>
                            <td>
                                <span class="fw-bold text-warning">{{ $lesson->stars_reward }} <i class="fa-solid fa-star"></i></span>
                            </td>
                            <td>{{ $lesson->sort_order }}</td>
                            <td>
                                @if($lesson->is_published)
                                    <span class="badge bg-success-subtle text-success">منشور</span>
                                @else
                                    <span class="badge bg-secondary-subtle text-muted">مسودة</span>
                                @endif
                            </td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <a href="{{ route('admin.lessons.edit', $lesson->id) }}" class="btn btn-sm btn-outline-primary" title="تعديل">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <form action="{{ route('admin.lessons.destroy', $lesson->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من حذف هذا الدرس؟')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="حذف">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="9" class="text-center py-5 text-muted">
                                <i class="fa-solid fa-box-open fs-1 mb-3 text-secondary"></i>
                                <div>لم يتم العثور على دروس مطابقة لمعايير البحث!</div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <!-- الترقيم -->
        <div class="mt-4">
            {{ $lessons->links() }}
        </div>
    </div>
</div>
@endsection
