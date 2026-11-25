@extends('admin.layout')

@section('title', $isEdit ? 'تعديل باقة: ' . $plan->name : 'إضافة باقة اشتراك جديدة')
@section('page_title', $isEdit ? 'تعديل باقة الاشتراك' : 'إضافة باقة اشتراك جديدة')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4 p-md-5">
                <form action="{{ $isEdit ? route('admin.plans.update', $plan->id) : route('admin.plans.store') }}" method="POST">
                    @csrf
                    @if($isEdit)
                        @method('PUT')
                    @endif

                    <div class="row g-3">
                        <div class="col-md-7">
                            <label class="form-label fw-bold">اسم الباقة <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" 
                                   value="{{ old('name', $plan->name) }}" placeholder="مثال: باقة 6 أشهر أو باقة العائلة السنوية" required>
                            @error('name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-5">
                            <label class="form-label fw-bold">المعرف البرمجي (Slug)</label>
                            <input type="text" name="slug" class="form-control @error('slug') is-invalid @enderror" 
                                   value="{{ old('slug', $plan->slug) }}" placeholder="مثال: semi-annual-6m">
                            @error('slug') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">السعر <span class="text-danger">*</span></label>
                            <input type="number" step="0.5" name="price" class="form-control @error('price') is-invalid @enderror" 
                                   value="{{ old('price', $plan->price) }}" placeholder="89.00" required>
                            @error('price') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">العملة <span class="text-danger">*</span></label>
                            <input type="text" name="currency" class="form-control @error('currency') is-invalid @enderror" 
                                   value="{{ old('currency', $plan->currency) }}" placeholder="SAR" required>
                            @error('currency') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">المدة باليوم <span class="text-danger">*</span></label>
                            <input type="number" name="duration_days" class="form-control @error('duration_days') is-invalid @enderror" 
                                   value="{{ old('duration_days', $plan->duration_days) }}" placeholder="365" required>
                            @error('duration_days') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-bold">الوصف المميز للباقة</label>
                            <textarea name="description" rows="3" class="form-control @error('description') is-invalid @enderror" 
                                      placeholder="مثال: توفير 40% - اشتراك سنوي شامل لكافة الألعاب والدروس لجميع أطفالك">{{ old('description', $plan->description) }}</textarea>
                            @error('description') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-12">
                            <div class="form-check form-switch p-0 pt-2 d-flex align-items-center gap-3">
                                <input class="form-check-input m-0 cursor-pointer" style="width: 2.8em; height: 1.5em;" type="checkbox" name="is_active" id="is_active" value="1" {{ old('is_active', $plan->is_active) ? 'checked' : '' }}>
                                <label class="form-check-label fw-bold cursor-pointer" for="is_active">
                                    تفعيل الباقة وإظهارها للآباء في تطبيق الهاتف
                                </label>
                            </div>
                        </div>

                        <div class="col-12 mt-4 d-flex justify-content-between">
                            <a href="{{ route('admin.plans.index') }}" class="btn btn-outline-secondary px-4">إلغاء وعودة</a>
                            <button type="submit" class="btn btn-lulu-primary px-5">
                                <i class="fa-solid fa-save me-1"></i> {{ $isEdit ? 'حفظ التعديلات' : 'إضافة الباقة' }}
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
