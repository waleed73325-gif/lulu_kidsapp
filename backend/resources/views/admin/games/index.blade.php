@extends('admin.layout')

@section('title', 'إدارة الألعاب التعليمية')
@section('page_title', 'الألعاب التعليمية التفاعلية')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h4 class="fw-bold mb-1">قائمة الألعاب التعليمية</h4>
        <p class="text-muted small m-0">تحكم بجميع الألعاب مثل مطابقة الحروف وترتيب الكلمات ومراحل كل لعبة</p>
    </div>
    <a href="{{ route('admin.games.create') }}" class="btn btn-lulu-primary">
        <i class="fa-solid fa-plus me-1"></i> إضافة لعبة جديدة
    </a>
</div>

<!-- فلترة الألعاب -->
<div class="card border-0 rounded-4 shadow-sm mb-4">
    <div class="card-body p-3">
        <form action="{{ route('admin.games.index') }}" method="GET" class="row g-2 align-items-center">
            <div class="col-md-4">
                <select name="game_type" class="form-select rounded-3">
                    <option value="">جميع أنواع الألعاب</option>
                    <option value="letter_matching" {{ request('game_type') == 'letter_matching' ? 'selected' : '' }}>مطابقة الحروف والكلمات</option>
                    <option value="letter_ordering" {{ request('game_type') == 'letter_ordering' ? 'selected' : '' }}>ترتيب حروف الكلمات</option>
                </select>
            </div>
            <div class="col-md-4">
                <select name="category_id" class="form-select rounded-3">
                    <option value="">جميع الجزر والتصنيفات</option>
                    @foreach($categories as $cat)
                        <option value="{{ $cat->id }}" {{ request('category_id') == $cat->id ? 'selected' : '' }}>{{ $cat->name_ar }}</option>
                    @endforeach
                </select>
            </div>
            <div class="col-md-4 d-flex gap-2">
                <button type="submit" class="btn btn-secondary rounded-3 flex-grow-1">
                    <i class="fa-solid fa-filter me-1"></i> تصفية
                </button>
                @if(request()->hasAny(['game_type', 'category_id']))
                    <a href="{{ route('admin.games.index') }}" class="btn btn-outline-secondary rounded-3">إلغاء</a>
                @endif
            </div>
        </form>
    </div>
</div>

<!-- جدول الألعاب -->
<div class="table-custom shadow-sm">
    <table class="table table-hover m-0">
        <thead>
            <tr>
                <th style="width: 70px;">الرمز</th>
                <th>عنوان اللعبة</th>
                <th>نوع اللعبة</th>
                <th>الجزيرة / التصنيف</th>
                <th>عدد المراحل / الأسئلة</th>
                <th>المكافأة والوصول</th>
                <th>الحالة</th>
                <th class="text-center" style="width: 220px;">الإجراءات</th>
            </tr>
        </thead>
        <tbody>
            @forelse($games as $game)
                <tr>
                    <td>
                        <div class="d-flex align-items-center justify-content-center rounded-3 text-white fw-bold" 
                             style="width: 44px; height: 44px; background-color: {{ $game->primary_color }};">
                            <i class="fa-solid fa-gamepad fs-5"></i>
                        </div>
                    </td>
                    <td>
                        <div class="fw-bold fs-6">{{ $game->title }}</div>
                        <small class="text-muted text-truncate d-inline-block" style="max-width: 280px;">{{ $game->description ?? 'بدون وصف' }}</small>
                    </td>
                    <td>
                        @if($game->game_type == 'letter_matching')
                            <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill fw-bold">
                                <i class="fa-solid fa-puzzle-piece me-1"></i> مطابقة الحروف
                            </span>
                        @elseif($game->game_type == 'letter_ordering')
                            <span class="badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill fw-bold">
                                <i class="fa-solid fa-arrow-down-a-z me-1"></i> ترتيب الحروف
                            </span>
                        @else
                            <span class="badge bg-secondary bg-opacity-10 text-secondary px-3 py-2 rounded-pill fw-bold">
                                تفاعلية
                            </span>
                        @endif
                    </td>
                    <td>
                        <span class="fw-bold text-dark">{{ $game->category->name_ar ?? 'عام' }}</span>
                    </td>
                    <td>
                        <a href="{{ route('admin.games.questions.index', $game->id) }}" class="btn btn-sm btn-outline-primary rounded-pill px-3 fw-bold">
                            <i class="fa-solid fa-layer-group me-1"></i> {{ $game->questions_count }} مرحلة / سؤال
                        </a>
                    </td>
                    <td>
                        <div class="d-flex align-items-center gap-1">
                            <span class="badge bg-warning bg-opacity-25 text-dark fw-bold rounded-pill">
                                ⭐ {{ $game->stars_reward }} نجوم
                            </span>
                            @if($game->access_level == 'free')
                                <span class="badge-free">مجانية</span>
                            @else
                                <span class="badge-premium">باقة المدفوعة</span>
                            @endif
                        </div>
                    </td>
                    <td>
                        @if($game->is_published)
                            <span class="badge bg-success bg-opacity-15 text-success rounded-pill px-2 py-1 fw-bold">منشورة</span>
                        @else
                            <span class="badge bg-secondary bg-opacity-15 text-muted rounded-pill px-2 py-1 fw-bold">مسودة</span>
                        @endif
                    </td>
                    <td class="text-center">
                        <div class="d-flex justify-content-center gap-1">
                            <a href="{{ route('admin.games.questions.index', $game->id) }}" class="btn btn-sm btn-outline-info rounded-3" title="إدارة مراحل اللعبة">
                                <i class="fa-solid fa-list-check"></i>
                            </a>
                            <a href="{{ route('admin.games.edit', $game->id) }}" class="btn btn-sm btn-outline-primary rounded-3" title="تعديل بيانات اللعبة">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </a>
                            <form action="{{ route('admin.games.destroy', $game->id) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من حذف هذه اللعبة ومراحلها بالكامل؟');" class="d-inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger rounded-3" title="حذف اللعبة">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="8" class="text-center py-5 text-muted">
                        <i class="fa-solid fa-gamepad fa-3x mb-3 text-secondary opacity-50"></i>
                        <h5>لا توجد ألعاب تعليمية مضافة حالياً</h5>
                        <p class="small">اضغط على زر "إضافة لعبة جديدة" لبدء إضافة لعبة جديدة بمراحلها المتعددة.</p>
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>
</div>

<div class="mt-4">
    {{ $games->links() }}
</div>
@endsection
