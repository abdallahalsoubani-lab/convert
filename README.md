# محول صيغ الصور - Image Converter

تطبيق macOS لتحويل صيغ الصور بسهولة وسرعة.

## المميزات

- ✅ تحويل الصور بين صيغ متعددة
- ✅ واجهة سهلة الاستخدام باللغة العربية
- ✅ دعم السحب والإفلات (Drag & Drop)
- ✅ معالجة دفعية لعدة صور في وقت واحد
- ✅ التحكم في جودة الصور المحولة
- ✅ دعم الصيغ الشائعة

## الصيغ المدعومة

- **PNG** - Portable Network Graphics
- **JPEG/JPG** - Joint Photographic Experts Group
- **TIFF** - Tagged Image File Format
- **BMP** - Bitmap
- **GIF** - Graphics Interchange Format
- **HEIC** - High Efficiency Image Container
- **WebP** - Web Picture format
- **PDF** - Portable Document Format

## متطلبات التشغيل

- macOS 13.0 أو أحدث
- Xcode 15.0 أو أحدث (للتطوير)

## كيفية فتح المشروع في Xcode

1. افتح ملف `ImageConverter.xcodeproj` في Xcode
2. اختر جهاز Mac كهدف للتشغيل (Target)
3. اضغط على زر التشغيل (▶️) أو `Command + R`

```bash
# أو من Terminal
cd /path/to/convert
open ImageConverter.xcodeproj
```

## طريقة الاستخدام

### الطريقة الأولى: السحب والإفلات
1. اسحب الصور من Finder
2. أفلتها في منطقة التطبيق
3. اختر الصيغة المطلوبة
4. اضبط الجودة (للصور JPEG/HEIC)
5. اضغط "حول الصور"
6. اختر مكان الحفظ

### الطريقة الثانية: اختيار الملفات
1. انقر على منطقة الإسقاط
2. اختر الصور من نافذة الحوار
3. اتبع نفس الخطوات السابقة

## هيكل المشروع

```
ImageConverter/
├── ImageConverter.xcodeproj/    # ملف مشروع Xcode
├── ImageConverter/
│   ├── ImageConverterApp.swift  # نقطة دخول التطبيق
│   ├── ContentView.swift        # واجهة المستخدم الرئيسية
│   ├── ImageConverter.swift     # منطق تحويل الصور
│   ├── Assets.xcassets/         # موارد التطبيق
│   └── ImageConverter.entitlements  # صلاحيات التطبيق
└── README.md                    # هذا الملف
```

## الميزات التقنية

- **Swift 5.0** - لغة البرمجة
- **SwiftUI** - إطار عمل واجهة المستخدم
- **AppKit** - معالجة الصور
- **Async/Await** - برمجة غير متزامنة
- **App Sandbox** - أمان محسّن

## الأذونات المطلوبة

التطبيق يحتاج الأذونات التالية:
- قراءة وكتابة الملفات المحددة من قبل المستخدم
- الوصول لمجلد التنزيلات

## ملاحظات التطوير

### Build Settings
- **Deployment Target**: macOS 13.0
- **Swift Version**: 5.0
- **Code Signing**: Automatic

### الصلاحيات (Entitlements)
- App Sandbox enabled
- User Selected Files (Read/Write)
- Downloads Folder (Read/Write)

## استكشاف الأخطاء

### المشكلة: التطبيق لا يفتح الصور
**الحل**: تأكد من أن الصيغة مدعومة وأن الصلاحيات ممنوحة

### المشكلة: فشل الحفظ
**الحل**: تحقق من صلاحيات الكتابة على المجلد المحدد

### المشكلة: بطء في التحويل
**الحل**: قلل عدد الصور المعالجة دفعة واحدة

## التطوير المستقبلي

- [ ] دعم المزيد من صيغ الصور
- [ ] تغيير حجم الصور
- [ ] ضغط الصور
- [ ] معاينة الصورة قبل التحويل
- [ ] دعم تحويل HEIC بشكل أصلي

## الترخيص

هذا المشروع مفتوح المصدر ومتاح للاستخدام الحر.

## المطور

تم التطوير باستخدام Claude Code

---

**ملاحظة**: هذا التطبيق مصمم خصيصاً لنظام macOS ولا يعمل على iOS أو iPadOS.
