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
}
