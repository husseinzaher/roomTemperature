// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Room Temperature';

  @override
  String get login => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logout => 'Log Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create an account';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get roomTemperature => 'Room Temperature';

  @override
  String get outsideTemperature => 'Outside Temperature';

  @override
  String get estimated => 'Estimated';

  @override
  String get sensor => 'Sensor';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get history => 'History';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get settings => 'Settings';

  @override
  String get thresholds => 'Thresholds';

  @override
  String get minTemperature => 'Minimum temperature';

  @override
  String get maxTemperature => 'Maximum temperature';

  @override
  String get enableAlerts => 'Enable alerts';

  @override
  String get units => 'Units';

  @override
  String get celsius => 'Celsius';

  @override
  String get fahrenheit => 'Fahrenheit';

  @override
  String get indoorOffset => 'Indoor calibration offset';

  @override
  String get indoorOffsetHint =>
      'Used to fine-tune the estimated room temperature.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Couldn\'t connect to the network. Check your connection.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorWeakPassword =>
      'That password is too weak. Choose a stronger one.';

  @override
  String get errorEmailInUse => 'That email is already in use.';

  @override
  String get notifications => 'Notifications';

  @override
  String get thresholdExceededTitle => 'Threshold exceeded';

  @override
  String thresholdExceededBody(double temp) {
    final intl.NumberFormat tempNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String tempString = tempNumberFormat.format(temp);

    return 'The temperature reached $tempString°, which is outside the configured range.';
  }

  @override
  String get normal => 'Normal';

  @override
  String get aboveThreshold => 'Above threshold';

  @override
  String get belowThreshold => 'Below threshold';

  @override
  String get inside => 'INSIDE';

  @override
  String get outside => 'OUTSIDE';

  @override
  String get insideHelp => 'How the indoor reading works';

  @override
  String get outsideHelp => 'About the outdoor conditions';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get humidity => 'Humidity';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String get pressure => 'Pressure';

  @override
  String get sunset => 'Sunset';

  @override
  String get uvIndex => 'UV Index';

  @override
  String get fiveDayForecast => '5-Day Forecast';

  @override
  String get airQualityMeter => 'Air Quality Meter';

  @override
  String get weatherRadar => 'Weather Radar';

  @override
  String get insideHelpBody =>
      'Most phones have no ambient-temperature sensor, so the indoor reading is estimated from the outdoor temperature plus your indoor offset. Calibrate the offset in Settings against a real thermometer. When your device does have a sensor, the reading is used directly and labelled Sensor.';

  @override
  String get outsideHelpBody =>
      'Outdoor conditions come from Open-Meteo for your current location, and refresh when you pull down or tap refresh.';

  @override
  String get close => 'Close';
}
