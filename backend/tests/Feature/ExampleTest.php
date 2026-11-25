<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * التحقق من توجيه الصفحة الرئيسية إلى لوحة التحكم
     */
    public function test_root_redirects_to_admin(): void
    {
        $response = $this->get('/');
        $response->assertStatus(302);
    }

    /**
     * التحقق من عمل صفحة تسجيل دخول المدير
     */
    public function test_admin_login_page_loads(): void
    {
        $response = $this->get('/admin/login');
        $response->assertStatus(200);
    }

    /**
     * التحقق من إعادة توجيه غير المسجلين إلى صفحة الدخول دون أخطاء
     */
    public function test_unauthenticated_user_redirected_to_admin_login(): void
    {
        $response = $this->get('/admin/dashboard');
        $response->assertRedirect('/admin/login');
    }

    /**
     * التحقق من تسجيل دخول المشرف بنجاح
     */
    public function test_admin_can_login_successfully(): void
    {
        $response = $this->post('/admin/login', [
            'email' => 'admin@lulukids.com',
            'password' => 'admin123456',
        ]);

        $response->assertRedirect('/admin/dashboard');
        $this->assertAuthenticated();
    }
}
