<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'لوحة التحكم') - لولو للأطفال</title>
    <!-- خط تجوال العربي للأطفال والتصميم الإداري -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800;900&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 RTL -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.rtl.min.css">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        :root {
            --lulu-primary: #6C5CE7;
            --lulu-primary-dark: #4834D4;
            --lulu-primary-light: #A29BFE;
            --lulu-yellow: #FDCB6E;
            --lulu-green: #00B894;
            --lulu-coral: #FF7675;
            --lulu-bg: #F8F9FE;
            --lulu-text: #2D3436;
        }

        body {
            font-family: 'Tajawal', sans-serif;
            background-color: var(--lulu-bg);
            color: var(--lulu-text);
            margin: 0;
            padding: 0;
        }

        .sidebar {
            width: 270px;
            background: #ffffff;
            min-height: 100vh;
            border-left: 1px solid #ECEEF7;
            position: fixed;
            top: 0;
            right: 0;
            z-index: 1000;
            box-shadow: -4px 0 20px rgba(108, 92, 231, 0.04);
            display: flex;
            flex-direction: column;
        }

        .sidebar-brand {
            padding: 24px 20px;
            border-bottom: 1px solid #ECEEF7;
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .brand-icon {
            width: 44px;
            height: 44px;
            background: linear-gradient(135deg, #FF7675, #FD79A8);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 22px;
            box-shadow: 0 4px 12px rgba(255, 118, 117, 0.3);
        }

        .brand-title {
            font-size: 20px;
            font-weight: 800;
            color: var(--lulu-primary);
            line-height: 1.2;
        }

        .brand-subtitle {
            font-size: 11px;
            color: #636E72;
            font-weight: 500;
        }

        .nav-menu {
            list-style: none;
            padding: 16px 12px;
            margin: 0;
            flex-grow: 1;
        }

        .nav-item {
            margin-bottom: 6px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: #636E72;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.2s ease;
        }

        .nav-link i {
            font-size: 18px;
            width: 24px;
            text-align: center;
        }

        .nav-link:hover {
            color: var(--lulu-primary);
            background: rgba(108, 92, 231, 0.08);
        }

        .nav-link.active {
            color: #ffffff;
            background: var(--lulu-primary);
            box-shadow: 0 4px 14px rgba(108, 92, 231, 0.35);
        }

        .main-wrapper {
            margin-right: 270px;
            padding: 24px 32px;
            min-height: 100vh;
        }

        .top-navbar {
            background: #ffffff;
            border-radius: 18px;
            padding: 14px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
            border: 1px solid #ECEEF7;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.02);
        }

        .stat-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 20px 24px;
            border: 1px solid #ECEEF7;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.02);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(108, 92, 231, 0.08);
        }

        .stat-icon {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }

        .btn-lulu-primary {
            background-color: var(--lulu-primary);
            color: #fff;
            border-radius: 12px;
            font-weight: 700;
            padding: 10px 20px;
            border: none;
            transition: all 0.2s;
        }

        .btn-lulu-primary:hover {
            background-color: var(--lulu-primary-dark);
            color: #fff;
            box-shadow: 0 4px 12px rgba(108, 92, 231, 0.3);
        }

        .table-custom {
            background: #fff;
            border-radius: 20px;
            border: 1px solid #ECEEF7;
            overflow: hidden;
        }

        .table-custom th {
            background-color: #F8F9FE;
            color: #636E72;
            font-weight: 700;
            padding: 16px 20px;
            border-bottom: 1px solid #ECEEF7;
        }

        .table-custom td {
            padding: 16px 20px;
            vertical-align: middle;
            border-bottom: 1px solid #F1F2F6;
        }

        .badge-free {
            background-color: rgba(0, 184, 148, 0.12);
            color: var(--lulu-green);
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 700;
        }

        .badge-premium {
            background-color: rgba(253, 203, 110, 0.25);
            color: #D68910;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 700;
        }

        .badge-pending {
            background-color: rgba(225, 112, 85, 0.15);
            color: #D63031;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 700;
        }

        .badge-verified {
            background-color: rgba(0, 184, 148, 0.15);
            color: var(--lulu-green);
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <!-- القائمة الجانبية (Sidebar) -->
    <aside class="sidebar">
        <a href="{{ route('admin.dashboard') }}" class="sidebar-brand">
            <div class="brand-icon">🐰</div>
            <div>
                <div class="brand-title">لوحة تحكم لولو</div>
                <div class="brand-subtitle">نظام إدارة المحتوى والاشتراكات</div>
            </div>
        </a>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>لوحة المؤشرات</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.lessons.index') }}" class="nav-link {{ request()->routeIs('admin.lessons.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-book-open-reader"></i>
                    <span>إدارة الدروس والأنشطة</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.games.index') }}" class="nav-link {{ request()->routeIs('admin.games.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-gamepad"></i>
                    <span>الألعاب التعليمية والمراحل</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.categories.index') }}" class="nav-link {{ request()->routeIs('admin.categories.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-compass"></i>
                    <span>جزر وتصنيفات لولو</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.plans.index') }}" class="nav-link {{ request()->routeIs('admin.plans.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-crown"></i>
                    <span>باقات الاشتراك (Lulu+)</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.payments.index') }}" class="nav-link {{ request()->routeIs('admin.payments.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-money-check-dollar"></i>
                    <span>التحويلات والاشتراكات</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.sounds.index') }}" class="nav-link {{ request()->routeIs('admin.sounds.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-volume-high"></i>
                    <span>الأصوات التحفيزية</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.users.index') }}" class="nav-link {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-users"></i>
                    <span>أولياء الأمور والأطفال</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="{{ route('admin.notifications.index') }}" class="nav-link {{ request()->routeIs('admin.notifications.*') ? 'active' : '' }}">
                    <i class="fa-solid fa-bell"></i>
                    <span>الإشعارات والتعميمات</span>
                </a>
            </li>
        </ul>

        <div class="p-3 border-top">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <div class="fw-bold fs-6">{{ Auth::user()->name ?? 'مدير النظام' }}</div>
                    <small class="text-muted">{{ Auth::user()->email ?? '' }}</small>
                </div>
                <form action="{{ route('admin.logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="btn btn-sm btn-outline-danger" title="تسجيل الخروج">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i>
                    </button>
                </form>
            </div>
        </div>
    </aside>

    <!-- المحتوى الرئيسي (Main Content) -->
    <main class="main-wrapper">
        <!-- شريط الرأس العلوي -->
        <header class="top-navbar">
            <h5 class="m-0 fw-bold">@yield('page_title', 'لوحة التحكم')</h5>
            <div class="d-flex align-items-center gap-3">
                <a href="{{ route('admin.lessons.create') }}" class="btn btn-lulu-primary btn-sm">
                    <i class="fa-solid fa-plus me-1"></i> إضافة درس جديد
                </a>
                <a href="http://localhost:8000/api/v1/categories" target="_blank" class="btn btn-sm btn-outline-secondary" title="فحص الـ REST API">
                    <i class="fa-solid fa-code me-1"></i> فحص API
                </a>
            </div>
        </header>

        <!-- التنبيهات -->
        @if(session('success'))
            <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm border-0" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i> {{ session('success') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        @endif

        @if(session('error'))
            <div class="alert alert-danger alert-dismissible fade show rounded-4 shadow-sm border-0" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> {{ session('error') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        @endif

        @yield('content')
    </main>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    @yield('scripts')
</body>
</html>
