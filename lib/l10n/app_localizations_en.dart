// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get receiveNotifications => 'Receive app notifications';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get language => 'Language';

  @override
  String get aboutCareLink => 'About CareLink';

  @override
  String get privacyMessage =>
      'Your privacy and account security are important to us.\n\n• Keep your login credentials private.\n\n• Use a strong password for your account.\n\n• Always log out when using a shared device.\n\n• Be careful when sharing personal information.';

  @override
  String get close => 'Close';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get careLinkDescription =>
      'CareLink connects people with caregivers and essential care services, making care more accessible, convenient and reliable.';

  @override
  String get appVersion => 'Version 1.0.0';
}
