<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\UploadedFile;
use App\Models\User;
use App\Models\Category;
use App\Models\Lesson;
use App\Models\Plan;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Foundation\Testing\DatabaseTransactions;

class LuluApiTest extends TestCase
{
    use DatabaseTransactions;

    /**
     * اختبار جلب جزر وتصنيفات لولو
     */
    public function test_can_fetch_categories(): void
    {
        $response = $this->getJson('/api/v1/categories');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'name_ar', 'slug', 'subtitle_ar', 'icon', 'lessons_count'],
                ],
            ]);
    }

    /**
     * اختبار جلب باقات الاشتراك
     */
    public function test_can_fetch_plans(): void
    {
        $response = $this->getJson('/api/v1/plans');

        $response->assertStatus(200)
            ->assertJson(['success' => true]);
    }

    /**
     * اختبار تسجيل دخول ولي الأمر
     */
    public function test_parent_can_login(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'parent@lulukids.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'data' => [
                    'user',
                    'token',
                    'has_active_subscription',
                ],
            ]);
    }

    /**
     * اختبار إنشاء طلب اشتراك لولي الأمر الموثق
     */
    public function test_parent_can_create_order(): void
    {
        $user = User::where('email', 'parent@lulukids.com')->first();
        $plan = Plan::first();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/orders', [
            'plan_id' => $plan->id,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonStructure([
                'data' => [
                    'order' => ['id', 'amount', 'currency', 'status'],
                    'bank_details' => ['bank_name', 'account_name', 'iban'],
                ],
            ]);
    }

    /**
     * اختبار حماية الدروس المدفوعة على الخادم (يمنع الوصول بدون اشتراك فعال)
     */
    public function test_premium_lesson_requires_subscription(): void
    {
        $premiumLesson = Lesson::where('access_level', 'premium')->first();

        if ($premiumLesson) {
            $unsubscribedUser = User::create([
                'name' => 'Unsubscribed Parent',
                'email' => 'unsubscribed_' . uniqid() . '@lulukids.com',
                'password' => bcrypt('password123'),
                'role' => 'parent',
            ]);

            // المستخدم ليس لديه اشتراك فعال، يجب أن يرجع الخادم 403
            $response = $this->actingAs($unsubscribedUser, 'sanctum')->getJson("/api/v1/lessons/{$premiumLesson->id}");

            $response->assertStatus(403)
                ->assertJson([
                    'success' => false,
                    'requires_subscription' => true,
                ]);
        }
    }

    /**
     * اختبار إرسال إثبات التحويل مع صورة إيصال حقيقية وتخزينها على القرص
     */
    public function test_parent_can_submit_manual_payment_with_proof_image(): void
    {
        Storage::fake('public');

        $user = User::where('email', 'parent@lulukids.com')->first();
        $plan = Plan::first();

        $order = Order::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'amount' => $plan->price,
            'currency' => $plan->currency,
            'status' => 'pending',
        ]);

        $file = UploadedFile::fake()->image('receipt.jpg', 600, 400);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/v1/orders/{$order->id}/payments", [
            'transfer_reference' => 'TEST-REF-9988',
            'proof' => $file,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'order_id' => $order->id,
                    'payment_status' => 'pending',
                ],
            ]);

        $payment = Payment::where('order_id', $order->id)->first();
        $this->assertNotNull($payment);
        $this->assertEquals('TEST-REF-9988', $payment->transfer_reference);
        $this->assertNotNull($payment->proof_path);
        Storage::disk('public')->assertExists($payment->proof_path);
    }

    /**
     * اختبار إلغاء اشتراك ولي الأمر من الخادم
     */
    public function test_parent_can_cancel_active_subscription(): void
    {
        $user = User::where('email', 'parent@lulukids.com')->first();

        // 1. تفعيل اشتراك تجريبي للمستخدم
        $this->actingAs($user, 'sanctum')->postJson('/api/v1/subscription/sandbox-activate')
            ->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertTrue($user->fresh()->hasActiveSubscription());

        // 2. طلب إلغاء الاشتراك
        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/subscription/cancel');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'has_active_subscription' => false,
                ],
            ]);

        // 3. التحقق من تحول حالة الاشتراك في قاعدة البيانات
        $this->assertFalse($user->fresh()->hasActiveSubscription());
    }

    /**
     * اختبار مزامنة واسترجاع نجوم وتقدم الطفل عبر السيرفر
     */
    public function test_child_progress_and_stars_persist_and_sync(): void
    {
        $user = User::where('email', 'parent@lulukids.com')->first();
        $child = $user->children()->first();

        // مزامنة رصيد نجوم ودروس جديدة
        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/progress/sync', [
            'child_id' => $child->id,
            'stars_count' => 64,
            'completed_lessons' => ['let_1', 'num_1', 'let_2', 'col_1'],
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'child_id' => $child->id,
                    'stars_count' => 64,
                ],
            ]);

        // جلب التقدم عبر endpoint مخصص
        $fetchRes = $this->actingAs($user, 'sanctum')->getJson("/api/v1/progress?child_id={$child->id}");
        $fetchRes->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'child_id' => $child->id,
                    'stars_count' => 64,
                ],
            ]);

        $this->assertContains('let_2', $fetchRes->json('data.completed_lessons'));

        // التأكد أيضاً من عودتها في بيانات الحساب /auth/me
        $meRes = $this->actingAs($user, 'sanctum')->getJson('/api/v1/auth/me');
        $meRes->assertStatus(200);
        $children = $meRes->json('data.user.children');
        $this->assertNotEmpty($children);
        $this->assertEquals(64, $children[0]['stars_count']);
    }

    /**
     * اختبار إضافة طفل جديد لحساب ولي الأمر
     */
    public function test_parent_can_add_new_child(): void
    {
        $user = User::where('email', 'parent@lulukids.com')->first();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/children/add', [
            'nickname' => 'سارة البطلة',
            'birth_year' => 2022,
            'avatar_id' => 'cat_kitty',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'child' => [
                        'nickname' => 'سارة البطلة',
                        'avatar_id' => 'cat_kitty',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('children', [
            'parent_user_id' => $user->id,
            'nickname' => 'سارة البطلة',
            'avatar_id' => 'cat_kitty',
        ]);
    }

    /**
     * اختبار إدارة باقات الاشتراك وتعديل الجزر من لوحة تحكم الأدمن
     */
    public function test_admin_can_manage_plans_and_update_category(): void
    {
        $admin = User::where('role', 'admin')->first();

        // 1. وصول الأدمن لصفحة الباقات
        $this->actingAs($admin)->get(route('admin.plans.index'))
            ->assertStatus(200);

        // 2. إنشاء باقة جديدة
        $storeRes = $this->actingAs($admin)->post(route('admin.plans.store'), [
            'name' => 'باقة التجربة الشهرية',
            'slug' => 'starter-1m-test',
            'duration_days' => 30,
            'price' => 15.00,
            'currency' => 'SAR',
            'description' => 'باقة مخصصة للشهر الأول',
            'is_active' => '1',
        ]);

        $storeRes->assertRedirect(route('admin.plans.index'));
        $this->assertDatabaseHas('plans', ['slug' => 'starter-1m-test']);

        // 3. تعديل الجزيرة
        $category = \App\Models\Category::first();
        $updateCatRes = $this->actingAs($admin)->put(route('admin.categories.update', $category->id), [
            'name_ar' => 'جزيرة الحروف المحدثة',
            'subtitle_ar' => 'وصف محدث للجزيرة',
            'sort_order' => 1,
            'is_active' => '1',
        ]);

        $updateCatRes->assertRedirect(route('admin.categories.index'));
        $this->assertEquals('جزيرة الحروف المحدثة', $category->fresh()->name_ar);
    }

    /**
     * اختبار مركز الإشعارات والتعميمات وقائمة أولياء الأمور من لوحة الإدارة
     */
    public function test_admin_can_send_broadcast_and_direct_notifications(): void
    {
        $admin = User::where('role', 'admin')->first();
        $parent = User::where('role', 'parent')->first();

        // 1. فحص صفحات الإشعارات
        $this->actingAs($admin)->get(route('admin.notifications.index'))
            ->assertStatus(200);

        $this->actingAs($admin)->get(route('admin.notifications.create'))
            ->assertStatus(200);

        // 2. إرسال تعميم عام لجميع أولياء الأمور
        $broadcastRes = $this->actingAs($admin)->post(route('admin.notifications.send'), [
            'target' => 'all',
            'type' => 'offer',
            'title' => 'عرض خاص نهاية الأسبوع! 🎉',
            'body' => 'خصم 40% على باقة الاشتراك السنوي لمدة يومين فقط.',
        ]);

        $broadcastRes->assertRedirect(route('admin.notifications.index'));
        $this->assertDatabaseHas('parent_notifications', [
            'title' => 'عرض خاص نهاية الأسبوع! 🎉',
            'type' => 'offer',
        ]);

        // 3. إرسال إشعار مخصص لولي أمر معين
        $directRes = $this->actingAs($admin)->post(route('admin.notifications.send'), [
            'target' => 'specific_user',
            'user_id' => $parent->id,
            'type' => 'announcement',
            'title' => 'رسالة خاصة لولي الأمر 🐰',
            'body' => 'شكراً لتشجيع طفلك على إتقان دروس الحروف والأرقام.',
        ]);

        $directRes->assertRedirect(route('admin.notifications.index'));
        $this->assertDatabaseHas('parent_notifications', [
            'user_id' => $parent->id,
            'title' => 'رسالة خاصة لولي الأمر 🐰',
            'type' => 'announcement',
        ]);

        // 4. فحص ظهور أولياء الأمور وتفاصيلهم
        $usersRes = $this->actingAs($admin)->get(route('admin.users.index'));
        $usersRes->assertStatus(200);
    }
}
