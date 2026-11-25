@extends('admin.layout')

@section('title', 'جزر وتصنيفات لولو')
@section('page_title', 'إدارة جزر التعلم والتصنيفات')

@section('content')
<div class="row g-4">
    <!-- قائمة الجزر الحالية -->
    <div class="col-lg-8">
        <div class="card table-custom border-0 shadow-sm">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-3"><i class="fa-solid fa-map-marked-alt text-primary me-2"></i>الجزر التعليمية الحالية</h6>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>اسم الجزيرة</th>
                                <th>المعرف (Slug)</th>
                                <th>عدد الدروس</th>
                                <th>الترتيب</th>
                                <th>الحالة</th>
                                <th>العمليات</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($categories as $category)
                                <tr>
                                    <td>
                                        <div class="fw-bold">{{ $category->name_ar }}</div>
                                        <small class="text-muted">{{ $category->subtitle_ar }}</small>
                                    </td>
                                    <td><code>{{ $category->slug }}</code></td>
                                    <td>
                                        <span class="badge bg-primary-subtle text-primary fw-bold">{{ $category->lessons_count }} درساً</span>
                                    </td>
                                    <td>{{ $category->sort_order }}</td>
                                    <td>
                                        @if($category->is_active)
                                            <span class="badge bg-success-subtle text-success">مفعل</span>
                                        @else
                                            <span class="badge bg-secondary-subtle text-muted">معطل</span>
                                        @endif
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center gap-1">
                                            <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editCatModal{{ $category->id }}" title="تعديل الجزيرة">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </button>
                                            <form action="{{ route('admin.categories.destroy', $category->id) }}" method="POST" onsubmit="return confirm('حذف الجزيرة سيؤدي لحذف كافة دروسها، هل أنت متأكد؟')">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-outline-danger" title="حذف">
                                                    <i class="fa-solid fa-trash-can"></i>
                                                </button>
                                            </form>
                                        </div>

                                        <!-- مودال تعديل الجزيرة -->
                                        <div class="modal fade" id="editCatModal{{ $category->id }}" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-dialog-centered">
                                                <div class="modal-content rounded-4 border-0">
                                                    <div class="modal-header border-0 pb-0">
                                                        <h6 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square text-primary me-2"></i>تعديل الجزيرة: {{ $category->name_ar }}</h6>
                                                        <button type="button" class="btn-close ms-0 me-auto" data-bs-dismiss="modal" aria-label="Close"></button>
                                                    </div>
                                                    <form action="{{ route('admin.categories.update', $category->id) }}" method="POST">
                                                        @csrf
                                                        @method('PUT')
                                                        <div class="modal-body py-3">
                                                            <div class="mb-3">
                                                                <label class="form-label fw-bold small">اسم الجزيرة <span class="text-danger">*</span></label>
                                                                <input type="text" name="name_ar" class="form-control" value="{{ $category->name_ar }}" required>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label fw-bold small">الوصف المختصر</label>
                                                                <input type="text" name="subtitle_ar" class="form-control" value="{{ $category->subtitle_ar }}">
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label fw-bold small">الترتيب</label>
                                                                <input type="number" name="sort_order" class="form-control" value="{{ $category->sort_order }}" required>
                                                            </div>
                                                            <div class="form-check form-switch">
                                                                <input class="form-check-input" type="checkbox" name="is_active" id="edit_active_{{ $category->id }}" value="1" {{ $category->is_active ? 'checked' : '' }}>
                                                                <label class="form-check-label fw-bold small" for="edit_active_{{ $category->id }}">تفعيل الجزيرة في التطبيق</label>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer border-0 pt-0">
                                                            <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">إلغاء</button>
                                                            <button type="submit" class="btn btn-sm btn-lulu-primary px-3">حفظ التعديلات</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- إضافة جزيرة جديدة -->
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
                <h6 class="fw-bold mb-3"><i class="fa-solid fa-plus-circle text-success me-2"></i>إضافة جزيرة جديدة</h6>
                <form action="{{ route('admin.categories.store') }}" method="POST">
                    @csrf
                    <div class="mb-3">
                        <label class="form-label fw-bold small">اسم الجزيرة / التصنيف <span class="text-danger">*</span></label>
                        <input type="text" name="name_ar" class="form-control" placeholder="مثال: جزيرة الحيوانات والطيور" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold small">الوصف المختصر</label>
                        <input type="text" name="subtitle_ar" class="form-control" placeholder="مثال: استكشف أصوات وأشكال الحيوانات">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold small">المعرف البرمجي (Slug)</label>
                        <input type="text" name="slug" class="form-control" placeholder="مثال: cat_animals (اتركه فارغاً للتوليد التلقائي)">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold small">الترتيب في الصفحة</label>
                        <input type="number" name="sort_order" class="form-control" value="10" min="0" required>
                    </div>

                    <div class="mb-3 form-check form-switch">
                        <input class="form-check-input" type="checkbox" name="is_active" id="is_active" value="1" checked>
                        <label class="form-check-label fw-bold small" for="is_active">تفعيل الجزيرة في التطبيق</label>
                    </div>

                    <button type="submit" class="btn btn-lulu-primary w-100">
                        <i class="fa-solid fa-save me-1"></i> حفظ وإضافة الجزيرة
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
