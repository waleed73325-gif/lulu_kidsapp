<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * التحقق من صلاحية وصول مدير النظام للوحة التحكم
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::check()) {
            return redirect()->route('admin.login')
                ->with('error', 'يرجى تسجيل الدخول أولاً للوصول للوحة التحكم.');
        }

        if (Auth::user()->role !== 'admin') {
            Auth::logout();
            return redirect()->route('admin.login')
                ->with('error', 'عذراً، هذا الحساب لا يملك صلاحيات مدير النظام.');
        }

        return $next($request);
    }
}
