import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In ar, this message translates to:
  /// **'فدان'**
  String get appName;

  /// Loading text on splash screen
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get splashLoading;

  /// Home page title
  ///
  /// In ar, this message translates to:
  /// **'مزرعتي'**
  String get homeTitle;

  /// Welcome message
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في فدان'**
  String get welcome;

  /// Empty state prompt on home screen
  ///
  /// In ar, this message translates to:
  /// **'أضف مزرعتك الأولى للبدء'**
  String get addFirstFarm;

  /// My farms section label
  ///
  /// In ar, this message translates to:
  /// **'مزارعي'**
  String get myFarms;

  /// Add farm button
  ///
  /// In ar, this message translates to:
  /// **'إضافة مزرعة'**
  String get addFarm;

  /// Farm profile page title
  ///
  /// In ar, this message translates to:
  /// **'إضافة مزرعة'**
  String get farmProfileTitle;

  /// Farm name field label
  ///
  /// In ar, this message translates to:
  /// **'اسم المزرعة'**
  String get farmNameLabel;

  /// Farm name field hint
  ///
  /// In ar, this message translates to:
  /// **'مثال: مزرعة الفيوم'**
  String get farmNameHint;

  /// Location section title
  ///
  /// In ar, this message translates to:
  /// **'موقع المزرعة'**
  String get farmLocationTitle;

  /// Use GPS location button
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get useCurrentLocation;

  /// Locating status text
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد الموقع...'**
  String get locating;

  /// Location confirmed label
  ///
  /// In ar, this message translates to:
  /// **'الموقع المحدد'**
  String get locationSet;

  /// Update location button
  ///
  /// In ar, this message translates to:
  /// **'إعادة تحديد الموقع'**
  String get updateLocation;

  /// Crops section title
  ///
  /// In ar, this message translates to:
  /// **'المحاصيل'**
  String get cropsTitle;

  /// Crops section subtitle
  ///
  /// In ar, this message translates to:
  /// **'اختر محاصيل مزرعتك'**
  String get cropsSubtitle;

  /// Save farm button
  ///
  /// In ar, this message translates to:
  /// **'حفظ المزرعة'**
  String get saveFarm;

  /// Farm saved success message
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المزرعة بنجاح'**
  String get farmSavedSuccess;

  /// Location permission denied error
  ///
  /// In ar, this message translates to:
  /// **'تم رفض إذن الموقع — يرجى السماح من الإعدادات'**
  String get locationPermissionDenied;

  /// Today's tasks section
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get todayTasks;

  /// Empty tasks message
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام اليوم'**
  String get noTasksToday;

  /// Irrigation task type
  ///
  /// In ar, this message translates to:
  /// **'ري'**
  String get irrigate;

  /// Fertilization task type
  ///
  /// In ar, this message translates to:
  /// **'تسميد'**
  String get fertilize;

  /// Spraying task type
  ///
  /// In ar, this message translates to:
  /// **'رش'**
  String get spray;

  /// No description provided for @cropTomato.
  ///
  /// In ar, this message translates to:
  /// **'طماطم'**
  String get cropTomato;

  /// No description provided for @cropPotato.
  ///
  /// In ar, this message translates to:
  /// **'بطاطس'**
  String get cropPotato;

  /// No description provided for @cropEggplant.
  ///
  /// In ar, this message translates to:
  /// **'باذنجان'**
  String get cropEggplant;

  /// No description provided for @cropPepper.
  ///
  /// In ar, this message translates to:
  /// **'فلفل'**
  String get cropPepper;

  /// No description provided for @cropWatermelon.
  ///
  /// In ar, this message translates to:
  /// **'بطيخ'**
  String get cropWatermelon;

  /// No description provided for @cropCantaloupe.
  ///
  /// In ar, this message translates to:
  /// **'شمام'**
  String get cropCantaloupe;

  /// No description provided for @cropHoneydew.
  ///
  /// In ar, this message translates to:
  /// **'كنتالوب'**
  String get cropHoneydew;

  /// No description provided for @cropCucumber.
  ///
  /// In ar, this message translates to:
  /// **'خيار'**
  String get cropCucumber;

  /// No description provided for @cropSquash.
  ///
  /// In ar, this message translates to:
  /// **'كوسة'**
  String get cropSquash;

  /// No description provided for @cropZucchini.
  ///
  /// In ar, this message translates to:
  /// **'قرع'**
  String get cropZucchini;

  /// No description provided for @weatherToday.
  ///
  /// In ar, this message translates to:
  /// **'الطقس اليوم'**
  String get weatherToday;

  /// No description provided for @temperature.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In ar, this message translates to:
  /// **'الرطوبة'**
  String get humidity;

  /// No description provided for @windSpeed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة الرياح'**
  String get windSpeed;

  /// No description provided for @rainExpected.
  ///
  /// In ar, this message translates to:
  /// **'متوقع هطول أمطار'**
  String get rainExpected;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// Generic error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، يرجى المحاولة مرة أخرى'**
  String get errorGeneric;

  /// No internet error message
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get errorNoInternet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
