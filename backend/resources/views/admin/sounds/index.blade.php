@extends('admin.layout')

@section('title', 'إدارة الأصوات التحفيزية والمؤثرات')
@section('page_title', 'التحكم بالأصوات التحفيزية ومؤثرات التشجيع')

@section('content')
<div class="row g-4">
    <!-- مقدمة وتوضيح -->
    <div class="col-12">
        <div class="card border-0 shadow-sm rounded-4" style="background: linear-gradient(135deg, #6C5CE710, #FDCB6E15);">
            <div class="card-body p-4 d-flex flex-wrap align-items-center justify-content-between gap-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-4 p-3 bg-white shadow-sm text-primary fs-3">
                        <i class="fa-solid fa-volume-high"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-1">إدارة الأصوات التحفيزية الخاصة بتطبيق لولو 🎵</h5>
                        <p class="text-muted small mb-0">
                            ارفع مقاطع صوتية مخصصة للتشجيع، التهنئة بجمع النجوم، أو الترحيب بالطفل. يقوم تطبيق الأطفال بسحب وتشغيل هذه الأصوات فور رفعها دون الحاجة لتحديث التطبيق.
                        </p>
                    </div>
                </div>
                <div>
                    <span class="badge bg-white text-dark shadow-sm px-3 py-2 rounded-pill fs-6 border">
                        <i class="fa-solid fa-wand-magic-sparkles text-warning me-1"></i> يتم تشغيل الصوتيات عبر السحابة فوراً
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- شبكة الأصوات التحفيزية -->
    @foreach($sounds as $sound)
        <div class="col-md-6">
            <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-body p-4 d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <div class="d-flex align-items-center gap-2">
                                <span class="badge bg-primary-subtle text-primary rounded-pill px-3 py-2 fw-bold">
                                    <i class="fa-solid fa-tag me-1"></i> {{ $sound->key }}
                                </span>
                            </div>
                            @if($sound->audio_path)
                                <span class="badge bg-success-subtle text-success rounded-pill px-3 py-2 fw-bold">
                                    <i class="fa-solid fa-circle-check me-1"></i> المقطع الصوتي جاهز
                                </span>
                            @else
                                <span class="badge bg-warning-subtle text-warning-emphasis rounded-pill px-3 py-2 fw-bold">
                                    <i class="fa-solid fa-circle-pause me-1"></i> لا يوجد صوت مرفوع
                                </span>
                            @endif
                        </div>

                        <h5 class="fw-bold text-dark mb-1">{{ $sound->title }}</h5>
                        <p class="text-muted small mb-3">{{ $sound->description }}</p>

                        <!-- مشغل الصوت الحالي إن وجد -->
                        @if($sound->audio_path)
                            <div class="p-3 bg-light rounded-3 mb-3 border">
                                <div class="d-flex align-items-center justify-content-between mb-2">
                                    <span class="small fw-bold text-muted">
                                        <i class="fa-solid fa-circle-play text-primary me-1"></i> الاستماع للمقطع المرفوع حالياً:
                                    </span>
                                    <form action="{{ route('admin.sounds.destroy', $sound->key) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من رغبتك بحذف هذا المقطع الصوتي؟');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2 rounded-pill small" title="حذف المقطع">
                                            <i class="fa-solid fa-trash-can me-1"></i> حذف
                                        </button>
                                    </form>
                                </div>
                                <audio controls class="w-100" style="height: 40px;">
                                    <source src="{{ asset('storage/' . $sound->audio_path) }}">
                                    متصفحك لا يدعم مشغل الصوتيات HTML5.
                                </audio>
                            </div>
                        @else
                            <div class="p-3 bg-light rounded-3 mb-3 border text-center text-muted small">
                                <i class="fa-solid fa-microphone-slash me-1 fs-5 d-block mb-1"></i>
                                لم يتم رفع مقطع لهذا الحدث بعد. يمكنك تسجيل أو اختيار ملف صوتي ورفعه أدناه.
                            </div>
                        @endif
                    </div>

                    <!-- نموذج رفع واستبدال الملف الصوتي -->
                    <form action="{{ route('admin.sounds.update', $sound->key) }}" method="POST" enctype="multipart/form-data" class="mt-2 pt-3 border-top">
                        @csrf
                        <label class="form-label small fw-bold text-dark mb-1">
                            {{ $sound->audio_path ? 'استبدال المقطع الصوتي الحالي:' : 'رفع مقطع صوتي جديد:' }}
                        </label>
                        <div class="input-group">
                            <input type="file" name="audio_file" class="form-control form-control-sm" required
                                   accept="audio/mp3,audio/wav,audio/m4a,audio/aac,audio/ogg,audio/mpeg,audio/*">
                            <button type="submit" class="btn btn-lulu-primary btn-sm px-3">
                                <i class="fa-solid fa-cloud-arrow-up me-1"></i> حفظ ورفع
                            </button>
                        </div>
                        <small class="text-muted" style="font-size: 11px;">الصيغ المدعومة: MP3, WAV, M4A, AAC, OGG (الحد الأقصى 15MB)</small>
                    </form>
                </div>
            </div>
        </div>
    @endforeach
</div>
@endsection
