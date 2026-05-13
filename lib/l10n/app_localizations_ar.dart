// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'فدان';

  @override
  String get tagline => 'مساعدك الزراعي الذكي';

  @override
  String get splashLoading => 'جارٍ التحميل...';

  @override
  String get signIn => 'سجل دخولك';

  @override
  String get phoneSubtitle => 'أدخل رقم هاتفك لتلقي رمز التحقق';

  @override
  String get countryCode => 'كود';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get sendCode => 'إرسال رمز التحقق';

  @override
  String get smsHint => 'سنرسل لك رمزاً مكوناً من 6 أرقام عبر رسالة نصية';

  @override
  String get back => 'رجوع';

  @override
  String get enterCode => 'أدخل رمز التحقق';

  @override
  String codeSentTo(String phone) {
    return 'أُرسل الرمز إلى $phone';
  }

  @override
  String get verify => 'تحقق';

  @override
  String resendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ث';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get orDivider => 'أو';

  @override
  String get signInWithGoogle => 'تسجيل الدخول عبر جوجل';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get homeTitle => 'مزرعتي';

  @override
  String get welcome => 'مرحباً بك في فدان';

  @override
  String get welcomeBody =>
      'أضف مزرعتك الأولى لتبدأ في استقبال\nمهام الري والتسميد اليومية';

  @override
  String get addFirstFarm => 'أضف مزرعتك الأولى للبدء';

  @override
  String get myFarms => 'مزارعي';

  @override
  String farmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مزارع',
      one: '$count مزرعة',
    );
    return '$_temp0';
  }

  @override
  String get addFarm => 'إضافة مزرعة';

  @override
  String get add => 'إضافة';

  @override
  String get todayTasks => 'مهام اليوم';

  @override
  String get noTasksToday => 'لا توجد مهام اليوم';

  @override
  String get tasksArriveDaily => 'ستصلك المهام يومياً عند الساعة 6 صباحاً';

  @override
  String get tasksLoadError => 'فشل تحميل المهام — اسحب للأسفل لإعادة المحاولة';

  @override
  String get offlineBanner => 'أنت غير متصل — تعرض بيانات محفوظة مسبقاً';

  @override
  String get taskUpdateError => 'فشل تحديث المهمة — تحقق من الاتصال';

  @override
  String get priorityHigh => 'عاجل';

  @override
  String get priorityNormal => 'اليوم';

  @override
  String get priorityLow => 'اختياري';

  @override
  String get taskDone => 'تم';

  @override
  String get taskSkip => 'تخطي';

  @override
  String waterDemand(String mm) {
    return '$mm مم';
  }

  @override
  String get farmProfileTitle => 'إضافة مزرعة';

  @override
  String get editFarm => 'تعديل المزرعة';

  @override
  String get deleteFarmTooltip => 'حذف المزرعة';

  @override
  String get deleteFarmTitle => 'حذف المزرعة؟';

  @override
  String get deleteFarmWarning =>
      'سيتم حذف هذه المزرعة نهائياً ولا يمكن التراجع عن ذلك.';

  @override
  String get delete => 'حذف';

  @override
  String get farmSavedSuccess => 'تم حفظ المزرعة بنجاح';

  @override
  String get farmUpdatedSuccess => 'تم تحديث المزرعة بنجاح';

  @override
  String get farmDeletedSuccess => 'تم حذف المزرعة';

  @override
  String get farmNameLabel => 'اسم المزرعة';

  @override
  String get farmNameHint => 'مثال: مزرعة الفيوم';

  @override
  String get farmLocationTitle => 'موقع المزرعة';

  @override
  String get useCurrentLocation => 'استخدام موقعي الحالي';

  @override
  String get locating => 'جارٍ تحديد الموقع...';

  @override
  String get locationSet => 'الموقع المحدد';

  @override
  String get tapMapToAdjust => 'اضغط على الخريطة لضبط الموقع';

  @override
  String get updateLocation => 'إعادة تحديد الموقع';

  @override
  String get cropsTitle => 'المحاصيل';

  @override
  String get cropsSubtitle => 'اختر محاصيل مزرعتك';

  @override
  String get plantingDate => 'تاريخ الزراعة';

  @override
  String get plantingDateSubtitle => 'متى زرعت هذا الموسم؟';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get saveFarm => 'حفظ المزرعة';

  @override
  String get updateFarm => 'تحديث المزرعة';

  @override
  String get locationPermissionDenied =>
      'تم رفض إذن الموقع — يرجى السماح من الإعدادات';

  @override
  String get weatherToday => 'الطقس اليوم';

  @override
  String get et0Label => 'الاحتياج المائي';

  @override
  String get rainfallLabel => 'هطول';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get maxTemp => 'الحرارة القصوى';

  @override
  String get humidity => 'الرطوبة';

  @override
  String get windSpeed => 'سرعة الرياح';

  @override
  String get rainExpected => 'متوقع هطول أمطار';

  @override
  String get irrigate => 'ري';

  @override
  String get fertilize => 'تسميد';

  @override
  String get inspect => 'تفتيش';

  @override
  String get cropTomato => 'طماطم';

  @override
  String get cropPotato => 'بطاطس';

  @override
  String get cropEggplant => 'باذنجان';

  @override
  String get cropPepper => 'فلفل';

  @override
  String get cropWatermelon => 'بطيخ';

  @override
  String get cropCantaloupe => 'شمام';

  @override
  String get cropHoneydew => 'كنتالوب';

  @override
  String get cropCucumber => 'خيار';

  @override
  String get cropSquash => 'كوسة';

  @override
  String get cropZucchini => 'قرع';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ، يرجى المحاولة مرة أخرى';

  @override
  String get errorNoInternet => 'لا يوجد اتصال بالإنترنت';
}
