@extends('admin.layout')

@section('title', $question->exists ? 'تعديل المرحلة: ' . $question->title : 'إضافة مرحلة / سؤال جديد')
@section('page_title', $question->exists ? 'تعديل مرحلة اللعبة' : 'إضافة مرحلة جديدة للعبة')

@section('content')
<div class="row justify-content-center">
    <div class="col-lg-10">
        <div class="card border-0 rounded-4 shadow-sm mb-4">
            <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-1 rounded-pill fw-bold">
                        {{ $game->title }}
                    </span>
                    <h5 class="fw-bold m-0 text-dark">
                        {{ $question->exists ? 'تعديل المرحلة' : 'إضافة مرحلة / سؤال جديد' }}
                    </h5>
                </div>
                <a href="{{ route('admin.games.questions.index', $game->id) }}" class="btn btn-sm btn-outline-secondary rounded-3">
                    <i class="fa-solid fa-arrow-right me-1"></i> عودة لمراحل اللعبة
                </a>
            </div>

            <div class="card-body p-4">
                <form action="{{ $question->exists ? route('admin.games.questions.update', [$game->id, $question->id]) : route('admin.games.questions.store', $game->id) }}" 
                      method="POST" enctype="multipart/form-data">
                    @csrf
                    @if($question->exists)
                        @method('PUT')
                    @endif

                    <!-- البيانات العامة للسؤال -->
                    <h6 class="fw-bold text-primary mb-3">
                        <i class="fa-solid fa-circle-info me-1"></i> البيانات الأساسية للمرحلة
                    </h6>
                    <div class="row g-3 mb-4">
                        <div class="col-md-8">
                            <label class="form-label fw-bold">عنوان المرحلة <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control rounded-3 @error('title') is-invalid @enderror" 
                                   value="{{ old('title', $question->title) }}" placeholder="مثال: المرحلة 1: حرف الألف" required>
                            @error('title') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-2">
                            <label class="form-label fw-bold">ترتيب المرحلة</label>
                            <input type="number" name="question_order" class="form-control rounded-3" 
                                   value="{{ old('question_order', $question->question_order ?? 1) }}" min="1" required>
                        </div>

                        <div class="col-md-2 d-flex align-items-center">
                            <div class="form-check form-switch mt-3">
                                <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" 
                                       {{ old('is_active', $question->is_active ?? true) ? 'checked' : '' }}>
                                <label class="form-check-label fw-bold me-1" for="is_active">نشطة</label>
                            </div>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label fw-bold">نص السؤال أو التوجيه المعروض للطفل <span class="text-danger">*</span></label>
                            <input type="text" name="prompt" class="form-control rounded-3 @error('prompt') is-invalid @enderror" 
                                   value="{{ old('prompt', $question->prompt) }}" placeholder="مثال: أي بطاقة تبدأ بحرف الألف (أ)؟" required>
                            @error('prompt') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-bold">تلميح مساعد (اختياري)</label>
                            <input type="text" name="hint" class="form-control rounded-3" 
                                   value="{{ old('hint', $question->hint) }}" placeholder="مثال: حيوان أليف سريع يحب الجزر">
                        </div>

                        <!-- الملف الصوتي للتوجيه -->
                        <div class="col-12">
                            <label class="form-label fw-bold">
                                <i class="fa-solid fa-volume-high text-primary me-1"></i> تسجيل صوتي للتوجيه أو السؤال (اختياري)
                            </label>
                            <input type="file" name="audio_file" class="form-control rounded-3" accept=".mp3,.wav,.m4a,.aac,.ogg">
                            <div class="form-text">يمكنك رفع تسجيل بصوت بشري أو تشجيعي لطرح هذا السؤال على الطفل (MP3, WAV حتى 15MB).</div>

                            @if($question->audio_path)
                                <div class="d-flex align-items-center gap-3 mt-2 p-2 bg-light rounded-3 border">
                                    <audio controls style="height: 36px;" class="flex-grow-1">
                                        <source src="{{ $question->audio_url }}" type="audio/mpeg">
                                    </audio>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="remove_audio" value="1" id="remove_audio">
                                        <label class="form-check-label text-danger fw-bold small" for="remove_audio">
                                            حذف الملف الصوتي الحالي
                                        </label>
                                    </div>
                                </div>
                            @endif
                        </div>
                    </div>

                    <hr class="my-4">

                    <!-- نموذج محتوى اللعبة التفاعلي حسب نوع اللعبة -->
                    @if($game->game_type == 'letter_matching')
                        <h6 class="fw-bold text-primary mb-3">
                            <i class="fa-solid fa-puzzle-piece me-1"></i> إعدادات سؤال مطابقة الحروف (Letter Matching)
                        </h6>

                        @php
                            $payload = $question->payload ?? [];
                            $options = $payload['options'] ?? [
                                ['text' => 'أ', 'subtext' => 'أرنب', 'emoji' => '🐰', 'is_correct' => true],
                                ['text' => 'ب', 'subtext' => 'بطة', 'emoji' => '🦆', 'is_correct' => false],
                                ['text' => 'ت', 'subtext' => 'تمساح', 'emoji' => '🐊', 'is_correct' => false],
                            ];
                        @endphp

                        <div class="row g-3 mb-4 p-3 bg-light rounded-4 border">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">الحرف المطلوب (Target Letter)</label>
                                <input type="text" name="target_letter" class="form-control rounded-3 text-center fs-4 fw-bold" 
                                       value="{{ old('target_letter', $payload['target_letter'] ?? 'أ') }}" placeholder="أ">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">الكلمة المرجعية</label>
                                <input type="text" name="target_word" class="form-control rounded-3" 
                                       value="{{ old('target_word', $payload['target_word'] ?? 'أرنب') }}" placeholder="أرنب">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">الرمز أو الإيموجي</label>
                                <input type="text" name="target_emoji" class="form-control rounded-3 text-center fs-4" 
                                       value="{{ old('target_emoji', $payload['target_emoji'] ?? '🐰') }}" placeholder="🐰">
                            </div>

                            <div class="col-12 mt-3">
                                <label class="form-label fw-bold d-block">
                                    خيارات الإجابة للطفل (حدد الخيار الصحيح بوضع علامة الصح):
                                </label>
                                <div class="row g-3">
                                    @for($i = 0; $i < 3; $i++)
                                        @php
                                            $opt = $options[$i] ?? ['text' => '', 'subtext' => '', 'emoji' => '⭐', 'is_correct' => ($i == 0)];
                                        @endphp
                                        <div class="col-md-4">
                                            <div class="card border rounded-3 p-3 {{ ($opt['is_correct'] ?? false) ? 'border-success bg-white shadow-sm' : 'bg-white' }}">
                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                    <span class="fw-bold small text-muted">بطاقة الخيار #{{ $i + 1 }}</span>
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="radio" name="correct_option_index" value="{{ $i }}" 
                                                               id="opt_correct_{{ $i }}" {{ ($opt['is_correct'] ?? false) ? 'checked' : '' }}>
                                                        <label class="form-check-label text-success fw-bold small" for="opt_correct_{{ $i }}">
                                                            الإجابة الصحيحة
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="mb-2">
                                                    <input type="text" name="option_letter[]" class="form-control form-control-sm text-center fw-bold fs-5" 
                                                           value="{{ $opt['text'] ?? '' }}" placeholder="الحرف (مثال: أ)">
                                                </div>
                                                <div class="mb-2">
                                                    <input type="text" name="option_word[]" class="form-control form-control-sm" 
                                                           value="{{ $opt['subtext'] ?? '' }}" placeholder="الكلمة (مثال: أرنب)">
                                                </div>
                                                <div>
                                                    <input type="text" name="option_emoji[]" class="form-control form-control-sm text-center" 
                                                           value="{{ $opt['emoji'] ?? '⭐' }}" placeholder="الإيموجي (مثال: 🐰)">
                                                </div>
                                            </div>
                                        </div>
                                    @endfor
                                </div>
                            </div>
                        </div>

                    @elseif($game->game_type == 'letter_ordering')
                        <h6 class="fw-bold text-primary mb-3">
                            <i class="fa-solid fa-arrow-down-a-z me-1"></i> إعدادات سؤال ترتيب الحروف (Letter Ordering)
                        </h6>

                        @php
                            $payload = $question->payload ?? [];
                            $scrambled = isset($payload['scrambled_letters']) ? implode(',', $payload['scrambled_letters']) : '';
                        @endphp

                        <div class="row g-3 mb-4 p-3 bg-light rounded-4 border">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">الكلمة المطلوب تكوينها بالترتيب الصحيح <span class="text-danger">*</span></label>
                                <input type="text" name="ordering_word" class="form-control rounded-3 fs-5 fw-bold" 
                                       value="{{ old('ordering_word', $payload['target_word'] ?? 'أرنب') }}" placeholder="أرنب">
                                <div class="form-text">سيتم تقسيم الكلمة إلى حروف قابلة للترتيب تلقائياً.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold">الرمز أو الإيموجي الدلالي للكلمة</label>
                                <input type="text" name="ordering_emoji" class="form-control rounded-3 text-center fs-4" 
                                       value="{{ old('ordering_emoji', $payload['hint_emoji'] ?? '🐰') }}" placeholder="🐰">
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">الحروف المبعثرة (اختياري - مفصولة بفاصلة)</label>
                                <input type="text" name="scrambled_letters" class="form-control rounded-3" 
                                       value="{{ old('scrambled_letters', $scrambled) }}" placeholder="مثال: ن,أ,ب,ر">
                                <div class="form-text">إذا تركت هذا الحقل فارغاً، سيقوم النظام ببعثرة حروف الكلمة تلقائياً للطفل.</div>
                            </div>
                        </div>

                    @else
                        <!-- الألعاب العامة -->
                        <h6 class="fw-bold text-primary mb-3">
                            <i class="fa-solid fa-code me-1"></i> حمولة السؤال التفاعلية (JSON Payload)
                        </h6>
                        <div class="mb-4">
                            <textarea name="raw_payload" rows="6" class="form-control font-monospace rounded-3" 
                                      dir="ltr">{{ json_encode($question->payload ?? [], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) }}</textarea>
                        </div>
                    @endif

                    <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                        <a href="{{ route('admin.games.questions.index', $game->id) }}" class="btn btn-light rounded-3 px-4">إلغاء</a>
                        <button type="submit" class="btn btn-lulu-primary rounded-3 px-5">
                            <i class="fa-solid fa-save me-1"></i>
                            {{ $question->exists ? 'تحديث المرحلة' : 'حفظ المرحلة' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
