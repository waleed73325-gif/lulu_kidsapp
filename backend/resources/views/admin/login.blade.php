<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل دخول المدير - لوحة تحكم لولو</title>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;600;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.rtl.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        body {
            font-family: 'Tajawal', sans-serif;
            background: linear-gradient(135deg, #F8F9FE 0%, #EDE9FE 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }

        .login-card {
            background: #ffffff;
            border-radius: 28px;
            box-shadow: 0 12px 40px rgba(108, 92, 231, 0.12);
            padding: 40px 36px;
            width: 100%;
            max-width: 440px;
            border: 1px solid #ECEEF7;
        }

        .rabbit-avatar {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #FF7675, #FD79A8);
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            margin: 0 auto 18px;
            box-shadow: 0 8px 20px rgba(255, 118, 117, 0.35);
        }

        .btn-lulu-login {
            background: #6C5CE7;
            color: #fff;
            font-weight: 700;
            font-size: 17px;
            border-radius: 14px;
            padding: 12px;
            width: 100%;
            border: none;
            transition: all 0.2s;
        }

        .btn-lulu-login:hover {
            background: #4834D4;
            color: #fff;
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(108, 92, 231, 0.35);
        }

        .form-control {
            border-radius: 14px;
            padding: 12px 16px;
            border: 1.5px solid #DFE6E9;
            background-color: #F8F9FE;
        }

        .form-control:focus {
            background-color: #ffffff;
            border-color: #6C5CE7;
            box-shadow: 0 0 0 3px rgba(108, 92, 231, 0.15);
        }

        .demo-badge {
            background: rgba(108, 92, 231, 0.08);
            border: 1px dashed #6C5CE7;
            border-radius: 14px;
            padding: 12px 16px;
            font-size: 13px;
            color: #2D3436;
        }
    </style>
</head>
<body>

    <div class="login-card">
        <div class="text-center">
            <div class="rabbit-avatar">🐰</div>
            <h4 class="fw-bold mb-1" style="color: #6C5CE7;">لوحة تحكم لولو</h4>
            <p class="text-muted small mb-4">بوابة الإدارة المركزية والتحكم في المحتوى</p>
        </div>

        @if(session('error'))
            <div class="alert alert-danger rounded-3 py-2 small mb-3">
                <i class="fa-solid fa-triangle-exclamation me-1"></i> {{ session('error') }}
            </div>
        @endif

        @if($errors->any())
            <div class="alert alert-danger rounded-3 py-2 small mb-3">
                @foreach ($errors->all() as $error)
                    <div>{{ $error }}</div>
                @endforeach
            </div>
        @endif

        <form action="{{ route('admin.login.post') }}" method="POST">
            @csrf
            <div class="mb-3">
                <label class="form-label fw-bold small text-muted">البريد الإلكتروني للإدارة</label>
                <div class="input-group">
                    <input type="email" name="email" class="form-control" value="{{ old('email', 'admin@lulukids.com') }}" required autofocus>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold small text-muted">كلمة المرور</label>
                <input type="password" name="password" class="form-control" value="admin123456" required>
            </div>

            <button type="submit" class="btn-lulu-login mb-4">
                <i class="fa-solid fa-right-to-bracket me-2"></i> دخول لوحة التحكم
            </button>

            <!-- تذكير ببيانات الدخول التجريبية -->
            <div class="demo-badge">
                <div class="fw-bold mb-1 text-primary"><i class="fa-solid fa-key me-1"></i> بيانات الدخول المعتمدة:</div>
                <div>البريد: <code>admin@lulukids.com</code></div>
                <div>كلمة المرور: <code>admin123456</code></div>
            </div>
        </form>
    </div>

</body>
</html>
