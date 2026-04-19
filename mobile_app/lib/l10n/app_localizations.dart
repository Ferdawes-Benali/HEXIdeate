// mobile_app/lib/l10n/app_localizations.dart
// ──────────────────────────────────────────────
// App Localizations - i18n support
// English, French, Arabic, Tunisian Derja
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _enStrings,
    'fr': _frStrings,
    'ar': _arStrings,
    'ar_TN': _derjaStrings,
  };

  String get String(String key) {
    final langCode = locale.languageCode;
    final regionCode = locale.countryCode;
    final fullKey = regionCode != null ? '${langCode}_$regionCode' : langCode;

    return _localizedValues[fullKey]?[key] ??
        _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters
  String get appName => String('app_name');
  String get welcome => String('welcome');
  String get login => String('login');
  String get logout => String('logout');
  String get dashboard => String('dashboard');
  String get camera => String('camera');
  String get chat => String('chat');
  String get profile => String('profile');
  String get medications => String('medications');
  String get takeMedication => String('take_medication');
  String get adherence => String('adherence');
  String get settings => String('settings');
  String get language => String('language');
  String get send => String('send');
  String get speak => String('speak');
  String get recording => String('recording');
  String get processing => String('processing');
  String get success => String('success');
  String get error => String('error');
  String get retry => String('retry');
  String get cancel => String('cancel');
  String get confirm => String('confirm');
  String get loading => String('loading');
  String get noMedications => String('no_medications');
  String get nextDose => String('next_dose');
  String get lastIntake => String('last_intake');
  String get skipRisk => String('skip_risk');
  String get highRisk => String('high_risk');
  String get lowRisk => String('low_risk');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English strings
const Map<String, String> _enStrings = {
  'app_name': 'DwaFi',
  'welcome': 'Welcome',
  'login': 'Login',
  'logout': 'Logout',
  'dashboard': 'Dashboard',
  'camera': 'Camera',
  'chat': 'Chat',
  'profile': 'Profile',
  'medications': 'Medications',
  'take_medication': 'Take Medication',
  'adherence': 'Adherence',
  'settings': 'Settings',
  'language': 'Language',
  'send': 'Send',
  'speak': 'Speak',
  'recording': 'Recording...',
  'processing': 'Processing...',
  'success': 'Success',
  'error': 'Error',
  'retry': 'Retry',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'loading': 'Loading...',
  'no_medications': 'No medications scheduled',
  'next_dose': 'Next dose',
  'last_intake': 'Last intake',
  'skip_risk': 'Skip risk',
  'high_risk': 'High risk',
  'low_risk': 'Low risk',
};

// French strings
const Map<String, String> _frStrings = {
  'app_name': 'DwaFi',
  'welcome': 'Bienvenue',
  'login': 'Connexion',
  'logout': 'Déconnexion',
  'dashboard': 'Tableau de bord',
  'camera': 'Caméra',
  'chat': 'Discussion',
  'profile': 'Profil',
  'medications': 'Médicaments',
  'take_medication': 'Prendre le médicament',
  'adherence': 'Observance',
  'settings': 'Paramètres',
  'language': 'Langue',
  'send': 'Envoyer',
  'speak': 'Parler',
  'recording': 'Enregistrement...',
  'processing': 'Traitement...',
  'success': 'Succès',
  'error': 'Erreur',
  'retry': 'Réessayer',
  'cancel': 'Annuler',
  'confirm': 'Confirmer',
  'loading': 'Chargement...',
  'no_medications': 'Aucun médicament prévu',
  'next_dose': 'Prochaine dose',
  'last_intake': 'Dernière prise',
  'skip_risk': 'Risque de oubli',
  'high_risk': 'Risque élevé',
  'low_risk': 'Risque faible',
};

// Standard Arabic strings
const Map<String, String> _arStrings = {
  'app_name': 'دوافي',
  'welcome': 'مرحباً',
  'login': 'تسجيل الدخول',
  'logout': 'تسجيل الخروج',
  'dashboard': 'الرئيسية',
  'camera': 'الكاميرا',
  'chat': 'المحادثة',
  'profile': 'ملفي',
  'medications': 'الأدوية',
  'take_medication': 'تناول الدواء',
  'adherence': 'الالتزام',
  'settings': 'الإعدادات',
  'language': 'اللغة',
  'send': 'إرسال',
  'speak': 'تحدث',
  'recording': 'جاري التسجيل...',
  'processing': 'جاري المعالجة...',
  'success': 'نجاح',
  'error': 'خطأ',
  'retry': 'إعادة المحاولة',
  'cancel': 'إلغاء',
  'confirm': 'تأكيد',
  'loading': 'جاري التحميل...',
  'no_medications': 'لا توجد أدوية محددة',
  'next_dose': 'الجرعة القادمة',
  'last_intake': 'آخر جرعة',
  'skip_risk': 'خطر النسيان',
  'high_risk': 'خطر عالي',
  'low_risk': 'خطر منخفض',
};

// Tunisian Arabic (Derja) strings
const Map<String, String> _derjaStrings = {
  'app_name': 'دوافي',
  'welcome': 'مرحباً بيك',
  'login': 'دخول',
  'logout': 'خروج',
  'dashboard': 'الصفحة الرئيسية',
  'camera': 'الة التصوير',
  'chat': 'الحوار',
  'profile': 'ملفي',
  'medications': 'الأدوية',
  'take_medication': 'خد药业',
  'adherence': 'الالتزام',
  'settings': 'الإعدادات',
  'language': 'اللغة',
  'send': 'ابعث',
  'speak': 'تكلم',
  'recording': 'جاري التسجيل...',
  'processing': 'جاري المعالجة...',
  'success': 'نجاح',
  'error': 'خطأ',
  'retry': 'حاول مرة أخرى',
  'cancel': 'إلغي',
  'confirm': 'أكد',
  'loading': 'جاري التحميل...',
  'no_medications': 'ماشي药业 محددة',
  'next_dose': 'الجرعة الجاية',
  'last_intake': 'آخر药业',
  'skip_risk': 'خطر النسيان',
  'high_risk': 'خطر عالي',
  'low_risk': 'خطر منخفض',
  // Additional Derja phrases used in the app
  'ya_haj': 'يا حاج',
  'labes': 'لابيس',
  'chwaya': 'شوية',
  'rabi_yachfik': 'رب ياشفيك',
  'medication_taken': '药业 تمّت',
  'medication_missed': '药业 نسيتها',
  'medication_wrong_time': 'الوقت ماهوش صحيح',
  'dont_worry': 'ما تحاتقلقش',
  'reminder': 'تذكير',
  'time_to_take': 'حان وقت药业',
};