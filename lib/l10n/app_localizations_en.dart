// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Feddan';

  @override
  String get tagline => 'Your Smart Farm Assistant';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get signIn => 'Sign In';

  @override
  String get phoneSubtitle =>
      'Enter your phone number to receive a verification code';

  @override
  String get countryCode => 'Code';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get sendCode => 'Send verification code';

  @override
  String get smsHint => 'We\'ll send you a 6-digit code via SMS';

  @override
  String get back => 'Back';

  @override
  String get enterCode => 'Enter verification code';

  @override
  String codeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get orDivider => 'or';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signOut => 'Sign out';

  @override
  String get homeTitle => 'My Farm';

  @override
  String get welcome => 'Welcome to Feddan';

  @override
  String get welcomeBody =>
      'Add your first farm to start receiving\ndaily irrigation and fertilisation tasks';

  @override
  String get addFirstFarm => 'Add your first farm to get started';

  @override
  String get myFarms => 'My Farms';

  @override
  String farmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count farms',
      one: '$count farm',
    );
    return '$_temp0';
  }

  @override
  String get addFarm => 'Add Farm';

  @override
  String get add => 'Add';

  @override
  String get todayTasks => 'Today\'s Tasks';

  @override
  String get noTasksToday => 'No tasks today';

  @override
  String get tasksArriveDaily => 'Tasks arrive daily at 6am Cairo time';

  @override
  String get tasksLoadError => 'Failed to load tasks — pull to refresh';

  @override
  String get offlineBanner => 'You are offline — showing saved farms';

  @override
  String get taskUpdateError => 'Failed to update task — check your connection';

  @override
  String get priorityHigh => 'URGENT';

  @override
  String get priorityNormal => 'TODAY';

  @override
  String get priorityLow => 'OPTIONAL';

  @override
  String get taskDone => 'Done';

  @override
  String get taskSkip => 'Skip';

  @override
  String waterDemand(String mm) {
    return '${mm}mm';
  }

  @override
  String get farmProfileTitle => 'Add Farm';

  @override
  String get editFarm => 'Edit Farm';

  @override
  String get deleteFarmTooltip => 'Delete farm';

  @override
  String get deleteFarmTitle => 'Delete Farm?';

  @override
  String get deleteFarmWarning =>
      'This farm will be permanently deleted. This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get farmSavedSuccess => 'Farm saved successfully';

  @override
  String get farmUpdatedSuccess => 'Farm updated successfully';

  @override
  String get farmDeletedSuccess => 'Farm deleted';

  @override
  String get farmNameLabel => 'Farm Name';

  @override
  String get farmNameHint => 'e.g. North Farm';

  @override
  String get farmLocationTitle => 'Farm Location';

  @override
  String get useCurrentLocation => 'Use my current location';

  @override
  String get locating => 'Locating...';

  @override
  String get locationSet => 'Location set';

  @override
  String get tapMapToAdjust => 'Tap the map to fine-tune the location';

  @override
  String get updateLocation => 'Update location';

  @override
  String get cropsTitle => 'Crops';

  @override
  String get cropsSubtitle => 'Select your farm crops';

  @override
  String get plantingDate => 'Planting Date';

  @override
  String get plantingDateSubtitle => 'When did you plant this season?';

  @override
  String get selectDate => 'Select date';

  @override
  String get saveFarm => 'Save Farm';

  @override
  String get updateFarm => 'Update Farm';

  @override
  String get locationPermissionDenied =>
      'Location permission denied — please allow in Settings';

  @override
  String get weatherToday => 'Today\'s Weather';

  @override
  String get et0Label => 'Water demand';

  @override
  String get rainfallLabel => 'Rainfall';

  @override
  String get temperature => 'Temperature';

  @override
  String get maxTemp => 'Max temp';

  @override
  String get humidity => 'Humidity';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String get rainExpected => 'Rain expected';

  @override
  String get irrigate => 'Irrigate';

  @override
  String get fertilize => 'Fertilize';

  @override
  String get inspect => 'Inspect';

  @override
  String get cropTomato => 'Tomato';

  @override
  String get cropPotato => 'Potato';

  @override
  String get cropEggplant => 'Eggplant';

  @override
  String get cropPepper => 'Pepper';

  @override
  String get cropWatermelon => 'Watermelon';

  @override
  String get cropCantaloupe => 'Cantaloupe';

  @override
  String get cropHoneydew => 'Honeydew';

  @override
  String get cropCucumber => 'Cucumber';

  @override
  String get cropSquash => 'Squash';

  @override
  String get cropZucchini => 'Zucchini';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong, please try again';

  @override
  String get errorNoInternet => 'No internet connection';
}
