@extends('admin.layout')

@section('title', 'مراحل وأسئلة: ' . $game->title)
@section('page_title', 'إدارة مراحل وأسئلة اللعبة')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div class="d-flex align-items-center gap-2 mb-1">
            <a href="{{ route('admin.games.index') }}" class="btn btn-sm btn-outline-secondary rounded-pill px-3">
                <i class="fa-solid fa-arrow-right me-1"></i> الألعاب
            </a>
            <h4 class="fw-bold m-0">{{ $game->title }}</h4>
            <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-1 rounded-pill fw-bold">
                {{ $game->game_type_name }}
            </span>
        </div>
        <p class="text-muted small m-0">تتكون هذه اللعبة من {{ $questions->count() }} مراحل / أسئلة. عند إجابة الطفل بشكل صحيح ينتقل للمرحلة التالية.</p>
    </div>
    <a href="{{ route('admin.games.questions.create', $game->id) }}" class="btn btn-lulu-primary">
        <i class="fa-solid fa-plus me-1"></i> إضافة مرحلة / سؤال جديد
    </a>
</div>

@if($questions->isEmpty())
    <div class="card border-0 rounded-4 shadow-sm text-center py-5">
        <div class="card-body">
            <i class="fa-solid fa-layer-group fa-3x text-muted opacity-50 mb-3"></i>
            <h5>لم تتم إضافة أي مراحل لهذه اللعبة بعد!</h5>
            <p class="text-muted small">اضغط على زر "إضافة مرحلة / سؤال جديد" لإنشاء أول مرحلة وسؤال للطفل في هذه اللعبة.</p>
            <a href="{{ route('admin.games.questions.create', $game->id) }}" class="btn btn-lulu-primary mt-2">
                <i class="fa-solid fa-plus me-1"></i> إضافة أول مرحلة
            </a>
        </div>
    </div>
@else
    <div class="row g-3">
        @foreach($questions as $q)
            <div class="col-md-6 col-lg-4">
                <div class="card border-0 rounded-4 shadow-sm h-100 position-relative">
                    <div class="card-body p-4 d-flex flex-column justify-content-between">
                        <div>
                            <!-- رأس البطاقة ورقم المرحلة -->
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="badge bg-secondary bg-opacity-15 text-dark fw-bold rounded-pill px-3 py-1">
                                    المرحلة #{{ $q->question_order }}
                                </span>
                                @if($q->is_active)
                                    <span class="badge bg-success bg-opacity-15 text-success rounded-pill px-2 py-1">نشط</span>
                                @else
                                    <span class="badge bg-danger bg-opacity-15 text-danger rounded-pill px-2 py-1">معطل</span>
                                @endif
                            </div>

                            <h5 class="fw-bold mb-2">{{ $q->title }}</h5>
                            <p class="text-dark fw-semibold mb-2">
                                <i class="fa-solid fa-question-circle text-primary me-1"></i>
                                {{ $q->prompt }}
                            </p>

                            @if($q->hint)
                                <div class="alert alert-light border py-2 px-3 rounded-3 small text-muted mb-3">
                                    <i class="fa-regular fa-lightbulb text-warning me-1"></i> تلميح: {{ $q->hint }}
                                </div>
                            @endif

                            <!-- تفاصيل ونمط الإجابة حسب نوع اللعبة -->
                            <div class="p-3 bg-light rounded-3 mb-3 border">
                                @if($game->game_type == 'letter_matching')
                                    <div class="small fw-bold text-muted mb-2">الحرف المطلوب والخيارات:</div>
                                    <div class="d-flex align-items-center gap-2 mb-2">
                                        <span class="badge bg-primary fs-6">{{ $q->payload['target_letter'] ?? '؟' }}</span>
                                        <span class="fw-bold">{{ $q->payload['target_word'] ?? '' }}</span>
                                        <span class="fs-5">{{ $q->payload['target_emoji'] ?? '' }}</span>
                                    </div>
                                    <div class="d-flex flex-wrap gap-1">
                                        @foreach($q->payload['options'] ?? [] as $opt)
                                            <span class="badge {{ ($opt['is_correct'] ?? false) ? 'bg-success' : 'bg-white text-dark border' }} rounded-pill px-2 py-1">
                                                {{ $opt['emoji'] ?? '' }} {{ $opt['text'] ?? '' }} ({{ $opt['subtext'] ?? '' }})
                                                @if($opt['is_correct'] ?? false) ✓ @endif
                                            </span>
                                        @endforeach
                                    </div>
                                @elseif($game->game_type == 'letter_ordering')
                                    <div class="small fw-bold text-muted mb-1">الكلمة المستهدفة:</div>
                                    <div class="d-flex align-items-center gap-2 mb-2">
                                        <span class="fw-bold fs-5 text-success">{{ $q->payload['target_word'] ?? '' }}</span>
                                        <span class="fs-4">{{ $q->payload['hint_emoji'] ?? '' }}</span>
                                    </div>
                                    <div class="small text-muted mb-1">الحروف المبعثرة للطفل:</div>
                                    <div class="d-flex gap-1">
                                        @foreach($q->payload['scrambled_letters'] ?? [] as $ltr)
                                            <span class="badge bg-white border text-dark fw-bold px-2 py-1">{{ $ltr }}</span>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="small text-muted font-monospace">بيانات تفاعلية جاهزة</div>
                                @endif
                            </div>

                            <!-- معاينة الصوت إن وُجد -->
                            @if($q->audio_path)
                                <div class="mb-3">
                                    <label class="small text-muted fw-bold d-block mb-1">
                                        <i class="fa-solid fa-volume-high text-primary me-1"></i> صوت التوجيه الصوتي:
                                    </label>
                                    <audio controls class="w-100" style="height: 36px;">
                                        <source src="{{ $q->audio_url }}" type="audio/mpeg">
                                    </audio>
                                </div>
                            @endif
                        </div>

                        <!-- أزرار الإجراءات -->
                        <div class="d-flex justify-content-end gap-2 pt-3 border-top mt-2">
                            <a href="{{ route('admin.games.questions.edit', [$game->id, $q->id]) }}" class="btn btn-sm btn-outline-primary rounded-3 px-3">
                                <i class="fa-solid fa-pen-to-square me-1"></i> تعديل
                            </a>
                            <form action="{{ route('admin.games.questions.destroy', [$game->id, $q->id]) }}" method="POST" 
                                  onsubmit="return confirm('هل تريد بالتأكيد حذف هذه المرحلة؟');" class="d-inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger rounded-3 px-3">
                                    <i class="fa-solid fa-trash-can me-1"></i> حذف
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        @endforeach
    </div>
@endif
@endsection
