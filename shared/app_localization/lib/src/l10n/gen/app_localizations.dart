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
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// The application's title.
  ///
  /// In ar, this message translates to:
  /// **'درجة حرارة الغرفة'**
  String get appTitle;

  /// Label for the login action/button.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// Label for the sign up action/button.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUp;

  /// Label for the logout action/button.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// Label for the email field.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// Label for the password field.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// Label for the confirm password field.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// Label for the forgot password link.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// Title/label for the reset password screen or action.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// Greeting shown on the login screen.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا بعودتك'**
  String get welcomeBack;

  /// Title/label for the create account screen or action.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get createAccount;

  /// Prompt shown on the login screen linking to sign up.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// Prompt shown on the sign up screen linking to login.
  ///
  /// In ar, this message translates to:
  /// **'هل لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// Label for the button that sends a password reset link.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط إعادة التعيين'**
  String get sendResetLink;

  /// Message shown after a password reset link has been sent.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني'**
  String get checkYourEmail;

  /// Title for the main dashboard screen.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// Label for the room (indoor) temperature reading.
  ///
  /// In ar, this message translates to:
  /// **'درجة حرارة الغرفة'**
  String get roomTemperature;

  /// Label for the outside temperature reading.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة الخارجية'**
  String get outsideTemperature;

  /// Badge label indicating a reading is estimated, not measured.
  ///
  /// In ar, this message translates to:
  /// **'مُقدَّرة'**
  String get estimated;

  /// Badge label indicating a reading came from a sensor.
  ///
  /// In ar, this message translates to:
  /// **'مستشعر'**
  String get sensor;

  /// Label preceding the timestamp of the last update.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get lastUpdated;

  /// Hint shown to invite the user to pull-to-refresh.
  ///
  /// In ar, this message translates to:
  /// **'اسحب للتحديث'**
  String get pullToRefresh;

  /// Title for the temperature history screen.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// Label for a daily average temperature value.
  ///
  /// In ar, this message translates to:
  /// **'المعدل اليومي'**
  String get dailyAverage;

  /// Empty state message for the history screen.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل حتى الآن'**
  String get noHistoryYet;

  /// Title for the settings screen.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// Title/label for the temperature thresholds section.
  ///
  /// In ar, this message translates to:
  /// **'الحدود'**
  String get thresholds;

  /// Label for the minimum temperature threshold field.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى لدرجة الحرارة'**
  String get minTemperature;

  /// Label for the maximum temperature threshold field.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأعلى لدرجة الحرارة'**
  String get maxTemperature;

  /// Label for the toggle that enables threshold alerts.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التنبيهات'**
  String get enableAlerts;

  /// Label for the temperature unit setting.
  ///
  /// In ar, this message translates to:
  /// **'وحدة القياس'**
  String get units;

  /// Label for the Celsius temperature unit.
  ///
  /// In ar, this message translates to:
  /// **'درجة سيلسيوس'**
  String get celsius;

  /// Label for the Fahrenheit temperature unit.
  ///
  /// In ar, this message translates to:
  /// **'درجة فهرنهايت'**
  String get fahrenheit;

  /// Label for the indoor temperature calibration offset setting.
  ///
  /// In ar, this message translates to:
  /// **'معايرة درجة الحرارة الداخلية'**
  String get indoorOffset;

  /// Explanatory hint for the indoor offset setting.
  ///
  /// In ar, this message translates to:
  /// **'تُستخدم هذه القيمة لمعايرة تقدير درجة حرارة الغرفة بشكل أدق.'**
  String get indoorOffsetHint;

  /// Label for a save action/button.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// Label for a cancel action/button.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// Label for a retry action/button.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// Generic error message shown when no more specific message applies.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما. حاول مرة أخرى.'**
  String get errorGeneric;

  /// Error message shown when a network request fails.
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالشبكة. تحقق من اتصالك بالإنترنت.'**
  String get errorNetwork;

  /// Error message shown when login credentials are invalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة.'**
  String get errorInvalidCredentials;

  /// Error message shown when a chosen password is too weak.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور ضعيفة جدًا. اختر كلمة مرور أقوى.'**
  String get errorWeakPassword;

  /// Error message shown when signing up with an email already in use.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد الإلكتروني مستخدم بالفعل.'**
  String get errorEmailInUse;

  /// Title for the notifications section/screen.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// Title of the notification shown when a threshold is exceeded.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز الحد المسموح'**
  String get thresholdExceededTitle;

  /// Body of the notification shown when a threshold is exceeded.
  ///
  /// In ar, this message translates to:
  /// **'بلغت درجة الحرارة {temp}° وهي خارج النطاق المحدد.'**
  String thresholdExceededBody(double temp);

  /// Status label indicating a reading is within normal range.
  ///
  /// In ar, this message translates to:
  /// **'طبيعية'**
  String get normal;

  /// Status label indicating a reading is above the configured threshold.
  ///
  /// In ar, this message translates to:
  /// **'أعلى من الحد المسموح'**
  String get aboveThreshold;

  /// Status label indicating a reading is below the configured threshold.
  ///
  /// In ar, this message translates to:
  /// **'أقل من الحد المسموح'**
  String get belowThreshold;
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
