# وثيقة المواصفات الهندسية والمعمارية - تطبيق لولو التعليمي للأطفال (Lulu Kids)

**تاريخ الإصدار:** أكتوبر 2026  
**الإصدار:** 1.0.0 (نطاق MVP)  
**الحالة:** معتمدة وموجهة للتنفيذ البرمجي  

---

## 1. خريطة الشاشات وتدفقات الاستخدام (Screen & User Flows)

تم تصميم التطبيق وفق فصل تام ومحكم بين مسارين للمستخدم:

### المسار الأول: عالم لولو للأطفال (Kids Mode)
* **المبدأ:** بيئة آمنة تماماً 100%، بدون روابط خارجية، بدون إعلانات، خطوط عربية كبيرة، تفاعل بصري وصوتي فوري، تدعم اتجاه RTL بالكامل.
* **الشاشات:**
  1. `SplashScreen`: شاشة ترحيبية ناطقة يظهر فيها الأرنب "لولو" مع صوت تحفيزي مرح.
  2. `ChildSelectScreen` (اختياري عند تعدد الأطفال): اختيار الطفل لملفه المستعار والأفاتار الخاص به.
  3. `LuluHomeScreen` (عالم لولو): خريطة جزر تفاعلية مبهجة:
     - **جزيرة الحروف**: تعلم الحروف ونطقها ومثال بصري.
     - **جزيرة الأرقام**: العد والأرقام بالنطق والأمثلة.
     - **جزيرة الألوان والأشكال**: أنشطة المطابقة والتمييز.
     - **خيمة حكايات لولو**: قصص قصيرة هادفة.
     - **حديقة الألعاب**: ألعاب بسيطة (سحب وإفلات، اختيار الصورة المناسبة).
  4. `LessonDetailScreen`: مشغل المحتوى المخصص للأطفال:
     - أزرار تحكم ضخمة (Touch target >= 56dp).
     - تعطيل الخروج غير المقصود.
     - نظام مكافآت تشجيعي (نجوم تتطاير وأصوات تصفيق عند إنهاء النشاط).
  5. `StarVaultScreen`: صندوق النجوم والشارات التي جمعها الطفل.
  6. `ParentalGateModal`: بوابة حماية تظهر عند لمس أيقونة "ولي الأمر" تتطلب حل مسألة حسابية تمنع دخول الطفل الصغير.

### المسار الثاني: بوابة ولي الأمر (Parental Portal)
* **الشاشات:**
  1. `ParentAuthScreen`: تسجيل دخول / إنشاء حساب ولي الأمر بالبريد أو الهاتف ورقم سري.
  2. `ParentDashboardScreen`: نظرة عامة على تقدم الطفل، الوقت المنقضي، وحالة الاشتراك.
  3. `ChildrenManagementScreen`: إضافة أو تعديل أطفال (اسم مستعار + الفئة العمرية + أيقونة الأفاتار).
  4. `SubscriptionPlansScreen`: عرض باقات الاشتراك (شهري / ربع سنوي / سنوي).
  5. `ManualPaymentScreen`: بيانات التحويل البنكي الرسمية + رفع رقم المرجع وصورة الإيصال.
  6. `OrderStatusScreen`: متابعة حالة التحويل (قيد المراجعة `pending`، تم التفعيل `verified`، أو مرفوض `rejected` مع توضيح السبب).
  7. `OfflineDownloadsScreen`: إدارة التنزيلات على ذاكرة الجهاز، فحص المساحة المتبقية، وخيار مسح الكاش.
  8. `AccountPrivacyScreen`: إدارة الحساب، سياسة الخصوصية، وخيار حذف الحساب بالكامل وفق معايير متاجر التطبيقات.

---

## 2. مخطط قاعدة البيانات ومحددات السلامة (Database ERD & Constraints)

### الجداول الأساسية (MySQL Engine: InnoDB, Charset: utf8mb4):

1. **`users` (أولياء الأمور):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `name`: VARCHAR(150) NOT NULL
   * `phone_or_email`: VARCHAR(191) NOT NULL UNIQUE
   * `password_hash`: VARCHAR(255) NOT NULL
   * `role`: ENUM('parent', 'admin') DEFAULT 'parent'
   * `status`: ENUM('active', 'suspended', 'pending_deletion') DEFAULT 'active'
   * `created_at`, `updated_at`: TIMESTAMP

2. **`children` (ملفات الأطفال):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `parent_user_id`: BIGINT UNSIGNED NOT NULL (FOREIGN KEY -> users.id CASCADE)
   * `nickname`: VARCHAR(100) NOT NULL (اسم مستعار لحماية الخصوصية)
   * `birth_year`: SMALLINT UNSIGNED NOT NULL (السنة فقط، دون تاريخ ميلاد كامل)
   * `avatar_id`: VARCHAR(50) DEFAULT 'rabbit_lulu'
   * `created_at`, `updated_at`: TIMESTAMP

3. **`plans` (خطط الاشتراك):**
   * `id`: INT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `name`: VARCHAR(100) NOT NULL
   * `duration_days`: INT UNSIGNED NOT NULL
   * `price`: DECIMAL(10, 2) NOT NULL
   * `currency`: VARCHAR(10) DEFAULT 'SAR'
   * `is_active`: BOOLEAN DEFAULT TRUE

4. **`orders` (طلبات الاشتراك):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `user_id`: BIGINT UNSIGNED NOT NULL (FOREIGN KEY -> users.id CASCADE)
   * `plan_id`: INT UNSIGNED NOT NULL (FOREIGN KEY -> plans.id)
   * `amount`: DECIMAL(10, 2) NOT NULL
   * `currency`: VARCHAR(10) NOT NULL
   * `status`: ENUM('pending', 'verified', 'rejected', 'cancelled') DEFAULT 'pending'
   * `created_at`, `updated_at`: TIMESTAMP

5. **`payments` (التحويلات اليدوية):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `order_id`: BIGINT UNSIGNED NOT NULL UNIQUE (FOREIGN KEY -> orders.id CASCADE)
   * `method`: ENUM('bank_transfer', 'wallet', 'other') DEFAULT 'bank_transfer'
   * `transfer_reference`: VARCHAR(191) NULL
   * `proof_path`: VARCHAR(255) NULL (مسار الصورة المشفرة في مساحة تخزين محمية)
   * `status`: ENUM('pending', 'verified', 'rejected') DEFAULT 'pending'
   * `reviewed_by`: BIGINT UNSIGNED NULL (FOREIGN KEY -> admin_users.id)
   * `reviewed_at`: TIMESTAMP NULL
   * `rejection_reason`: VARCHAR(255) NULL
   * `created_at`: TIMESTAMP

6. **`subscriptions` (الاشتراكات المفعلة):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `user_id`: BIGINT UNSIGNED NOT NULL (FOREIGN KEY -> users.id CASCADE)
   * `order_id`: BIGINT UNSIGNED NOT NULL UNIQUE (FOREIGN KEY -> orders.id)
   * `starts_at`: TIMESTAMP NOT NULL
   * `ends_at`: TIMESTAMP NOT NULL
   * `status`: ENUM('active', 'expired', 'revoked') DEFAULT 'active'
   * INDEX `idx_user_active_sub` (`user_id`, `status`, `ends_at`)

7. **`categories` (تصنيفات المحتوى التعليمي):**
   * `id`: INT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `name_ar`: VARCHAR(100) NOT NULL
   * `slug`: VARCHAR(100) NOT NULL UNIQUE
   * `icon`: VARCHAR(150) NULL
   * `sort_order`: INT DEFAULT 0

8. **`lessons` (الدروس والأنشطة):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `category_id`: INT UNSIGNED NOT NULL (FOREIGN KEY -> categories.id)
   * `title`: VARCHAR(200) NOT NULL
   * `description`: TEXT NULL
   * `media_type`: ENUM('video', 'audio', 'interactive_quiz') DEFAULT 'video'
   * `media_path`: VARCHAR(255) NOT NULL
   * `access_level`: ENUM('free', 'premium') DEFAULT 'free'
   * `sort_order`: INT DEFAULT 0
   * `published_at`: TIMESTAMP NULL
   * INDEX `idx_cat_access` (`category_id`, `access_level`, `published_at`)

9. **`lesson_progress` (تتبع إنجاز الطفل):**
   * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
   * `child_id`: BIGINT UNSIGNED NOT NULL (FOREIGN KEY -> children.id CASCADE)
   * `lesson_id`: BIGINT UNSIGNED NOT NULL (FOREIGN KEY -> lessons.id CASCADE)
   * `progress_percent`: TINYINT UNSIGNED DEFAULT 0
   * `stars_earned`: TINYINT UNSIGNED DEFAULT 0
   * `is_completed`: BOOLEAN DEFAULT FALSE
   * `completed_at`: TIMESTAMP NULL
   * `updated_at`: TIMESTAMP
   * UNIQUE KEY `uk_child_lesson` (`child_id`, `lesson_id`)

10. **`devices` (إدارة أجهزة الحساب):**
    * `id`: BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
    * `user_id`: BIGINT UNSIGNED NOT NULL (FOREIGN KEY -> users.id CASCADE)
    * `device_identifier_hash`: VARCHAR(191) NOT NULL
    * `device_name`: VARCHAR(100) NULL
    * `last_seen_at`: TIMESTAMP NULL
    * `status`: ENUM('active', 'blocked') DEFAULT 'active'
    * UNIQUE KEY `uk_user_device` (`user_id`, `device_identifier_hash`)

---

## 3. مواصفات واجهات REST API (API Specifications)

* **Base URL:** `/api/v1`
* **معيار الاستجابة الموحد (Unified JSON Envelope):**
```json
{
  "success": true,
  "message": "تم تنفيذ العملية بنجاح",
  "data": { ... }
}
```

### نقاط النهاية الأساسية (Endpoints):
1. **المصادقة وحساب ولي الأمر:**
   * `POST /auth/register`: تسجيل حساب جديد (اسم، بريد/هاتف، كلمة مرور).
   * `POST /auth/login`: تسجيل دخول والحصول على Sanctum Token.
   * `GET /auth/me`: بيانات ولي الأمر مع قائمة الأطفال والاشتراك الحالي.
   * `POST /auth/logout`: إلغاء صلاحية الرمز.

2. **ملفات الأطفال:**
   * `GET /children`: قائمة أطفال ولي الأمر المسجلين.
   * `POST /children`: إضافة طفل (اسم مستعار + سنة الميلاد + الأفاتار).

3. **المحتوى والدروس:**
   * `GET /categories`: قائمة التصنيفات (حروف، أرقام، ألوان، قصص).
   * `GET /lessons?category_id={id}`: قائمة الدروس (مع إشارة هل الدرس مجاني أم مقفل).
   * `GET /lessons/{id}`: تفاصيل الدرس. إذا كان `premium`، يتحقق الخادم أولاً من سريان اشتراك المستخدم.
   * `GET /lessons/{id}/download-ticket`: إصدار رابط موقع مؤقت (Temporary Signed URL) لتحميل الدرس على الجهاز للاستخدام دون إنترنت.

4. **الطلبات والاشتراكات والتحويل اليدوي:**
   * `GET /plans`: قائمة الباقات والأسعار.
   * `POST /orders`: إنشاء طلب اشتراك جديد لباقة محددة (حالة الطلب: `pending`).
   * `POST /orders/{id}/payments`: رفع إثبات التحويل (رقم المرجع وصورة الإشعار).
   * `GET /subscription/status`: الاستعلام عن حالة الاشتراك الحالي الفعال.

5. **المزامنة دون إنترنت (Offline Sync):**
   * `POST /progress/sync`: مزامنة سجل تقدم الطفل والنجوم المكتسبة محلياً مع قاعدة البيانات المركزية.

---

## 4. معمارية تطبيق Flutter (Clean & Modular Architecture)

```text
lib/
├── core/
│   ├── constants/       # الثوابت، مسارات الصور والأصوات
│   ├── network/         # إعدادات Dio، معالجة الأخطاء، الـ Interceptors
│   ├── storage/         # التخزين المحلي (Hive / SQLite) للدروس المحملة والتقدم
│   ├── theme/           # الألوان المرحة للطفل، ثيم RTL، ونظام الخط العربي (Tajawal / Cairo)
│   ├── utils/           # حماية بوابة الوالدين، مدير تشغيل الصوت والمؤثرات
│   └── widgets/         # الأزرار الكرتونية، إطارات الألعاب، بطاقات الدروس
├── features/
│   ├── auth/            # تسجيل ودخول ولي الأمر
│   ├── splash/          # واجهة البداية وحركة لولو الترحيبية
│   ├── home/            # جزر لولو التعليمية وقائمة الأنشطة
│   ├── lessons/         # عرض الأنشطة والمحتوى التعليمي
│   ├── player/          # مشغل الفيديو والوسائط المخصص للأطفال
│   ├── progress/        # شاشة مكافآت النجوم والإنجازات
│   ├── parent_portal/   # إدارة الأطفال، الاشتراكات، وإيصالات الدفع
│   └── offline/         # مدير التنزيلات للمشاهدة بدون إنترنت
└── main.dart
```
