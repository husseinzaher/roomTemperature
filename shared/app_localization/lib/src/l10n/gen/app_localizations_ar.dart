// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'درجة حرارة الغرفة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get createAccount => 'إنشاء حساب جديد';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get checkYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get roomTemperature => 'درجة حرارة الغرفة';

  @override
  String get outsideTemperature => 'درجة الحرارة الخارجية';

  @override
  String get estimated => 'مُقدَّرة';

  @override
  String get sensor => 'مستشعر';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get history => 'السجل';

  @override
  String get dailyAverage => 'المعدل اليومي';

  @override
  String get noHistoryYet => 'لا يوجد سجل حتى الآن';

  @override
  String get settings => 'الإعدادات';

  @override
  String get thresholds => 'الحدود';

  @override
  String get minTemperature => 'الحد الأدنى لدرجة الحرارة';

  @override
  String get maxTemperature => 'الحد الأعلى لدرجة الحرارة';

  @override
  String get enableAlerts => 'تفعيل التنبيهات';

  @override
  String get units => 'وحدة القياس';

  @override
  String get celsius => 'درجة سيلسيوس';

  @override
  String get fahrenheit => 'درجة فهرنهايت';

  @override
  String get indoorOffset => 'معايرة درجة الحرارة الداخلية';

  @override
  String get indoorOffsetHint =>
      'تُستخدم هذه القيمة لمعايرة تقدير درجة حرارة الغرفة بشكل أدق.';

  @override
  String get indoorCalibration => 'معايرة درجة الحرارة الداخلية';

  @override
  String get indoorCalibrationHint =>
      'أدخل درجة حرارة الغرفة الفعلية من ميزان حرارة. المعايرة تتم بالكامل دون اتصال بالإنترنت.';

  @override
  String get indoorCurrentEstimate => 'التقدير الحالي';

  @override
  String get indoorReferenceTemperature => 'درجة حرارة الغرفة الفعلية';

  @override
  String get indoorCalibrate => 'معايرة';

  @override
  String get indoorResetCalibration => 'إعادة ضبط المعايرة';

  @override
  String get indoorCalibrationSaved => 'تم حفظ المعايرة محليًا.';

  @override
  String get indoorCalibrationWarning =>
      'الجهاز مشحون أو ساخن. يمكن حفظ النقطة، لكن الدقة قد تنخفض.';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorNetwork => 'تعذر الاتصال بالشبكة. تحقق من اتصالك بالإنترنت.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorWeakPassword =>
      'كلمة المرور ضعيفة جدًا. اختر كلمة مرور أقوى.';

  @override
  String get errorEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get thresholdExceededTitle => 'تجاوز الحد المسموح';

  @override
  String thresholdExceededBody(double temp) {
    final intl.NumberFormat tempNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String tempString = tempNumberFormat.format(temp);

    return 'بلغت درجة الحرارة $tempString° وهي خارج النطاق المحدد.';
  }

  @override
  String get normal => 'طبيعية';

  @override
  String get aboveThreshold => 'أعلى من الحد المسموح';

  @override
  String get belowThreshold => 'أقل من الحد المسموح';

  @override
  String get inside => 'الداخل';

  @override
  String get outside => 'الخارج';

  @override
  String get insideHelp => 'كيف تعمل قراءة الداخل';

  @override
  String get outsideHelp => 'عن أحوال الطقس بالخارج';

  @override
  String get feelsLike => 'الإحساس الفعلي';

  @override
  String get humidity => 'الرطوبة';

  @override
  String get windSpeed => 'سرعة الرياح';

  @override
  String get pressure => 'الضغط الجوي';

  @override
  String get sunset => 'الغروب';

  @override
  String get uvIndex => 'الأشعة فوق البنفسجية';

  @override
  String get fiveDayForecast => 'توقعات ٥ أيام';

  @override
  String get airQualityMeter => 'مقياس جودة الهواء';

  @override
  String get weatherRadar => 'رادار الطقس';

  @override
  String get insideHelpBody =>
      'تُقدَّر درجة الحرارة الداخلية من مستشعرات الجهاز الحرارية على الهاتف، دون إنترنت أو موقع. عايرها من الإعدادات مقابل ميزان حرارة حقيقي. إذا وُجد مستشعر محيط أو مستشعر بلوتوث، تُستخدم قراءته مباشرة.';

  @override
  String get outsideHelpBody =>
      'تُجلب أحوال الطقس بالخارج من Open-Meteo حسب موقعك الحالي، وتُحدَّث عند السحب للأسفل أو الضغط على زر التحديث.';

  @override
  String get close => 'إغلاق';
}
