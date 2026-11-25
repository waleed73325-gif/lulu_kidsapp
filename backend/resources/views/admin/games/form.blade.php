@extends('admin.layout')

@section('title', $game->exists ? 'تعديل اللعبة: ' . $game->title : 'إضافة لعبة تعليمية جديدة')
@section('page_title', $game->exists ? 'تعديل بيانات اللعبة' : 'إضافة لعبة تعليمية جديدة')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-9">
        <div class="card border-0 rounded-4 shadow-sm">
            <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                <h5 class="fw-bold m-0 text-primary">
                    <i class="fa-solid fa-gamepad me-2"></i>
                    {{ $game->exists ? 'تعديل بيانات اللعبة التعليمية' : 'بيانات اللعبة التعليمية الجديدة' }}
                </h5>
                <a href="{{ route('admin.games.index') }}" class="btn btn-sm btn-outline-secondary rounded-3">
                    <i class="fa-solid fa-arrow-right me-1"></i> عودة للقائمة
                </a>
            </div>
            <div class="card-body p-4">
                <form action="{{ $game->exists ? route('admin.games.update', $game->id) : route('admin.games.store') }}" method="POST">
                    @csrf
                    @if($game->exists)
                        @method('PUT')
                    @endif

                    <div class="row g-3">
                        <!-- عنوان اللعبة -->
                        <div class="col-md-8">
                            <label class="form-label fw-bold">عنوان اللعبة <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control rounded-3 @error('title') is-invalid @enderror" 
                                   value="{{ old('title', $game->title) }}" placeholder="مثال: لعبة مطابقة الحروف والكلمات" required>
                            @error('title') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <!-- نوع اللعبة -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">نوع وميكانيكية اللعبة <span class="text-danger">*</span></label>
                            <select name="game_type" class="form-select rounded-3 @error('game_type') is-invalid @enderror" required>
                                <option value="letter_matching" {{ old('game_type', $game->game_type) == 'letter_matching' ? 'selected' : '' }}>
                                    🧩 مطابقة الحروف والكلمات (Letter Matching)
                                </option>
                                <option value="letter_ordering" {{ old('game_type', $game->game_type) == 'letter_ordering' ? 'selected' : '' }}>
                                    🔤 ترتيب حروف الكلمة (Letter Ordering)
                                </option>
                            </select>
                            @error('game_type') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <!-- الجزيرة / التصنيف -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">الجزيرة التابعة لها</label>
                            <select name="category_id" class="form-select rounded-3">
                                <option value="">-- عام (بدون تصنيف محدد) --</option>
                                @foreach($categories as $cat)
                                    <option value="{{ $cat->id }}" {{ old('category_id', $game->category_id) == $cat->id ? 'selected' : '' }}>
                                        {{ $cat->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- مستوى الوصول -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">مستوى الوصول <span class="text-danger">*</span></label>
                            <select name="access_level" class="form-select rounded-3">
                                <option value="free" {{ old('access_level', $game->access_level) == 'free' ? 'selected' : '' }}>مجانية للجميع (Free)</option>
                                <option value="premium" {{ old('access_level', $game->access_level) == 'premium' ? 'selected' : '' }}>تتطلب اشتراك ولي أمر (Premium)</option>
                            </select>
                        </div>

                        <!-- وصف اللعبة -->
                        <div class="col-12">
                            <label class="form-label fw-bold">وصف تشجيعي للطفل</label>
                            <textarea name="description" rows="2" class="form-control rounded-3" 
                                      placeholder="مثال: هيا نطابق الحرف مع الصورة المناسبة لنكسب النجوم!">{{ old('description', $game->description) }}</textarea>
                        </div>

                        <!-- اللون المميز -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">اللون المميز (Primary Color)</label>
                            <div class="input-group">
                                <input type="color" name="primary_color" class="form-control form-control-color rounded-start-3" 
                                       value="{{ old('primary_color', $game->primary_color ?? '#6C5CE7') }}" title="اختر اللون">
                                <input type="text" class="form-control rounded-end-3" 
                                       value="{{ old('primary_color', $game->primary_color ?? '#6C5CE7') }}" readonly>
                            </div>
                        </div>

                        <!-- رمز الأيقونة -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">رمز الأيقونة</label>
                            <input type="text" name="icon" class="form-control rounded-3" 
                                   value="{{ old('icon', $game->icon ?? 'videogame_asset_rounded') }}" placeholder="videogame_asset_rounded" required>
                            <small class="text-muted">videogame_asset_rounded أو extension_rounded أو sort_by_alpha_rounded</small>
                        </div>

                        <!-- نجوم المكافأة -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">نجوم المكافأة عند الفوز</label>
                            <input type="number" name="stars_reward" class="form-control rounded-3" 
                                   value="{{ old('stars_reward', $game->stars_reward ?? 5) }}" min="1" max="20" required>
                        </div>

                        <!-- ترتيب الظهور والفرز -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">ترتيب الظهور</label>
                            <input type="number" name="sort_order" class="form-control rounded-3" 
                                   value="{{ old('sort_order', $game->sort_order ?? 1) }}" min="0" required>
                        </div>

                        <!-- حالة النشر -->
                        <div class="col-md-6 d-flex align-items-center">
                            <div class="form-check form-switch mt-3">
                                <input class="form-check-input" type="checkbox" name="is_published" value="1" id="is_published" 
                                       {{ old('is_published', $game->is_published) ? 'checked' : '' }}>
                                <label class="form-check-label fw-bold me-2" for="is_published">
                                    نشر اللعبة وإتاحتها في تطبيق الأطفال
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                        <a href="{{ route('admin.games.index') }}" class="btn btn-light rounded-3 px-4">إلغاء</a>
                        <button type="submit" class="btn btn-lulu-primary rounded-3 px-5">
                            <i class="fa-solid fa-save me-1"></i>
                            {{ $game->exists ? 'حفظ التعديلات' : 'حفظ ومتابعة لإضافة المراحل' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
