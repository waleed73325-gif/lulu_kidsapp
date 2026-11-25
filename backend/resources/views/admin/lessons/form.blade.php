@extends('admin.layout')

@section('title', $isEdit ? 'تعديل الدرس: ' . $lesson->title : 'إضافة درس تعليمي جديد')
@section('page_title', $isEdit ? 'تعديل بيانات الدرس' : 'إضافة نشاط أو درس جديد إلى عالم لولو')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-10">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4 p-md-5">
                <form action="{{ $isEdit ? route('admin.lessons.update', $lesson->id) : route('admin.lessons.store') }}" method="POST" enctype="multipart/form-data">
                    @csrf
                    @if($isEdit)
                        @method('PUT')
                    @endif

                    <div class="row g-3">
                        <!-- الجزيرة والتصنيف -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">الجزيرة / التصنيف <span class="text-danger">*</span></label>
                            <select name="category_id" class="form-select @error('category_id') is-invalid @enderror" required>
                                <option value="">اختر الجزيرة...</option>
                                @foreach($categories as $category)
                                    <option value="{{ $category->id }}" {{ old('category_id', $lesson->category_id) == $category->id ? 'selected' : '' }}>
                                        {{ $category->name_ar }}
                                    </option>
                                @endforeach
                            </select>
                            @error('category_id') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <!-- عنوان الدرس -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">عنوان الدرس <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control @error('title') is-invalid @enderror" 
                                   value="{{ old('title', $lesson->title) }}" placeholder="مثال: حرف الألف (أ) أو الرقم واحد (١)" required>
                            @error('title') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <!-- المحتوى العربي الأساسي والكلمة والمثال -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">المحتوى العربي (حرف / رقم / شكل) <span class="text-danger">*</span></label>
                            <input type="text" name="content_arabic" class="form-control @error('content_arabic') is-invalid @enderror" 
                                   value="{{ old('content_arabic', $lesson->content_arabic) }}" placeholder="مثال: أ أو ٥ أو مربع" required>
                            @error('content_arabic') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">مثال مصور / كلمة توضيحية</label>
                            <input type="text" name="example_word" class="form-control" 
                                   value="{{ old('example_word', $lesson->example_word) }}" placeholder="مثال: أرنب 🐰 أو شمس ☀️">
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">العنوان الفرعي (Subtitle)</label>
                            <input type="text" name="subtitle" class="form-control" 
                                   value="{{ old('subtitle', $lesson->subtitle) }}" placeholder="مثال: أ - أرنب">
                        </div>

                        <!-- نص الحوار والتشجيع من لولو -->
                        <div class="col-12">
                            <label class="form-label fw-bold">حديث وتشجيع لولو مع الطفل (Narration Text)</label>
                            <textarea name="narration_text" class="form-control" rows="3" 
                                      placeholder="مثال: مرحباً يا بطل! أنا صديقك لولو، وأول حرف في اسمي هو حرف الألف..">{{ old('narration_text', $lesson->narration_text) }}</textarea>
                            <small class="text-muted">هذا النص ينطقه الأرنب لولو لتشجيع الطفل وتوجيهه عند فتح النشاط.</small>
                        </div>

                        <!-- رفع المقطع الصوتي المخصص للدرس -->
                        <div class="col-12">
                            <div class="p-3 p-md-4 rounded-4 border bg-light">
                                <label class="form-label fw-bold text-dark d-flex align-items-center gap-2 mb-1">
                                    <i class="fa-solid fa-microphone-lines text-primary fs-5"></i>
                                    <span>المقطع الصوتي المخصص للدرس (Custom Audio Upload)</span>
                                    <span class="badge bg-secondary-subtle text-secondary fw-normal">اختياري</span>
                                </label>
                                <p class="text-muted small mb-3">
                                    ارفع مقطعاً صوتياً بنطقك أو بتسجيل استوديو خاص للحرف أو الكلمة (يدعم صيغ MP3, WAV, M4A, AAC, OGG حتى 15 ميجابايت).
                                </p>

                                @if($lesson->audio_path)
                                    <div class="alert alert-white border rounded-3 p-3 mb-3 d-flex flex-wrap align-items-center justify-content-between gap-3 shadow-sm">
                                        <div class="d-flex align-items-center gap-3">
                                            <span class="badge bg-success text-white p-2 rounded-circle fs-6">
                                                <i class="fa-solid fa-volume-high"></i>
                                            </span>
                                            <div>
                                                <div class="fw-bold small text-dark mb-1">المقطع الصوتي المحفوظ حالياً للدرس:</div>
                                                <audio controls class="mt-1" style="height: 36px; max-width: 320px;">
                                                    <source src="{{ asset('storage/' . $lesson->audio_path) }}">
                                                    متصفحك لا يدعم مشغل الصوتيات.
                                                </audio>
                                            </div>
                                        </div>
                                        <div class="form-check text-danger">
                                            <input class="form-check-input" type="checkbox" name="remove_audio" id="remove_audio" value="1">
                                            <label class="form-check-label fw-bold small cursor-pointer" for="remove_audio">
                                                <i class="fa-solid fa-trash-can me-1"></i> حذف المقطع الصوتي الحالي
                                            </label>
                                        </div>
                                    </div>
                                @endif

                                <div class="input-group">
                                    <input type="file" name="audio_file" class="form-control @error('audio_file') is-invalid @enderror" 
                                           accept="audio/mp3,audio/wav,audio/m4a,audio/aac,audio/ogg,audio/mpeg,audio/*">
                                    <label class="input-group-text"><i class="fa-solid fa-file-audio text-primary"></i></label>
                                </div>
                                @error('audio_file') <div class="text-danger small mt-1">{{ $message }}</div> @enderror
                                <small class="text-muted d-block mt-1">عند اختيار ملف جديد، سيتم استبدال المقطع القديم تلقائياً.</small>
                            </div>
                        </div>

                        <!-- مستوى الوصول والنوع واللون -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">مستوى الوصول <span class="text-danger">*</span></label>
                            <select name="access_level" class="form-select" required>
                                <option value="free" {{ old('access_level', $lesson->access_level) === 'free' ? 'selected' : '' }}>مجاني للجميع (Free)</option>
                                <option value="premium" {{ old('access_level', $lesson->access_level) === 'premium' ? 'selected' : '' }}>يتطلب اشتراكاً فعالاً (Lulu+ Premium)</option>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">نوع المحتوى</label>
                            <select name="media_type" class="form-select">
                                <option value="interactive" {{ old('media_type', $lesson->media_type) === 'interactive' ? 'selected' : '' }}>نشاط تفاعلي / صوتي</option>
                                <option value="video" {{ old('media_type', $lesson->media_type) === 'video' ? 'selected' : '' }}>فيديو تعليمي</option>
                                <option value="audio" {{ old('media_type', $lesson->media_type) === 'audio' ? 'selected' : '' }}>ملف صوتي / قصة مسجلة</option>
                            </select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">اللون المميز للدرس</label>
                            <input type="color" name="primary_color" class="form-control form-control-color w-100" 
                                   value="{{ old('primary_color', $lesson->primary_color ?? '#6C5CE7') }}" title="اختر لون الدرس">
                        </div>

                        <!-- النجوم والترتيب -->
                        <div class="col-md-4">
                            <label class="form-label fw-bold">مكافأة النجوم المكتسبة</label>
                            <input type="number" name="stars_reward" class="form-control" 
                                   value="{{ old('stars_reward', $lesson->stars_reward ?? 3) }}" min="1" max="10" required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">الترتيب في القائمة</label>
                            <input type="number" name="sort_order" class="form-control" 
                                   value="{{ old('sort_order', $lesson->sort_order ?? 1) }}" min="0" required>
                        </div>

                        <div class="col-md-4 d-flex align-items-center mt-4">
                            <div class="form-check form-switch fs-5">
                                <input class="form-check-input" type="checkbox" name="is_published" id="is_published" value="1" 
                                       {{ old('is_published', $lesson->is_published ?? true) ? 'checked' : '' }}>
                                <label class="form-check-label fs-6 fw-bold" for="is_published">نشر الدرس في التطبيق فوراً</label>
                            </div>
                        </div>
                    </div>

                    <hr class="my-4">

                    <div class="d-flex justify-content-end gap-2">
                        <a href="{{ route('admin.lessons.index') }}" class="btn btn-light px-4">إلغاء</a>
                        <button type="submit" class="btn btn-lulu-primary px-5">
                            <i class="fa-solid fa-floppy-disk me-1"></i> {{ $isEdit ? 'حفظ التعديلات' : 'إضافة الدرس الآن' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
