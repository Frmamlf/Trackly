# Trackly 📱

تطبيق Flutter لتتبع المهام والأنشطة يدعم الأندرويد والآيفون.

## المميزات ✨

- إضافة وحذف المهام
- تتبع حالة إكمال المهام
- حفظ البيانات محلياً
- واجهة مستخدم عربية جميلة
- دعم الأندرويد والآيفون

## التقنيات المستخدمة 🛠️

- **Flutter**: إطار العمل الرئيسي
- **Provider**: إدارة الحالة
- **SharedPreferences**: حفظ البيانات محلياً
- **Material Design**: تصميم الواجهات

## متطلبات التشغيل 📋

- Flutter SDK 3.0.0 أو أحدث
- Dart SDK
- Android Studio / VS Code
- جهاز أندرويد أو محاكي
- macOS + Xcode للتطوير على iOS

## طريقة التشغيل 🚀

1. استنساخ المشروع:
```bash
git clone <repository-url>
cd Trackly
```

2. تثبيت التبعيات:
```bash
flutter pub get
```

3. تشغيل التطبيق:
```bash
flutter run
```

## بناء التطبيق للإنتاج 📦

### للأندرويد:
```bash
flutter build apk --release
# أو
flutter build appbundle --release
```

### للآيفون:
```bash
flutter build ios --release
```

## هيكل المشروع 📁

```
lib/
├── main.dart              # نقطة دخول التطبيق
├── providers/             # مزودي الحالة
│   └── tracking_provider.dart
└── screens/               # شاشات التطبيق
    ├── home_screen.dart
    └── add_item_screen.dart
```

## المساهمة 🤝

نرحب بالمساهمات! يرجى:

1. عمل Fork للمستودع
2. إنشاء فرع جديد للميزة
3. إجراء التغييرات
4. إرسال Pull Request

## الترخيص 📄

هذا المشروع مرخص تحت رخصة MIT.