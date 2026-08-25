import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

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
    Locale('en'),
    Locale('ru'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MobScanner'**
  String get appTitle;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Scan to capture your first document'**
  String get libraryEmptySubtitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'My documents'**
  String get libraryTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search documents and text'**
  String get searchHint;

  /// No description provided for @actionScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get actionScan;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get actionMove;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get actionExportPdf;

  /// No description provided for @actionExportText.
  ///
  /// In en, this message translates to:
  /// **'Export text'**
  String get actionExportText;

  /// No description provided for @actionRunOcr.
  ///
  /// In en, this message translates to:
  /// **'Recognize text (OCR)'**
  String get actionRunOcr;

  /// No description provided for @actionAddPage.
  ///
  /// In en, this message translates to:
  /// **'Add page'**
  String get actionAddPage;

  /// No description provided for @actionRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get actionRotate;

  /// No description provided for @actionCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get actionCrop;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get actionNewFolder;

  /// No description provided for @filterOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get filterOriginal;

  /// No description provided for @filterGrayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get filterGrayscale;

  /// No description provided for @filterBlackWhite.
  ///
  /// In en, this message translates to:
  /// **'B&W'**
  String get filterBlackWhite;

  /// No description provided for @filterMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic color'**
  String get filterMagic;

  /// No description provided for @dialogRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename document'**
  String get dialogRenameTitle;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete document?'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get dialogDeleteMessage;

  /// No description provided for @dialogNewFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'New folder name'**
  String get dialogNewFolderTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsOcrLanguages.
  ///
  /// In en, this message translates to:
  /// **'OCR languages'**
  String get settingsOcrLanguages;

  /// No description provided for @settingsScanQuality.
  ///
  /// In en, this message translates to:
  /// **'Scan quality'**
  String get settingsScanQuality;

  /// No description provided for @settingsExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Default export format'**
  String get settingsExportFormat;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @qualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get qualityLow;

  /// No description provided for @qualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get qualityMedium;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get qualityHigh;

  /// No description provided for @ocrRunning.
  ///
  /// In en, this message translates to:
  /// **'Recognizing text…'**
  String get ocrRunning;

  /// No description provided for @ocrDone.
  ///
  /// In en, this message translates to:
  /// **'Text recognized'**
  String get ocrDone;

  /// No description provided for @ocrNoText.
  ///
  /// In en, this message translates to:
  /// **'No text found'**
  String get ocrNoText;

  /// No description provided for @pagesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String pagesLabel(int count);

  /// No description provided for @documentDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan {date}'**
  String documentDefaultTitle(String date);

  /// No description provided for @folderAll.
  ///
  /// In en, this message translates to:
  /// **'All documents'**
  String get folderAll;

  /// No description provided for @snackExported.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully'**
  String get snackExported;

  /// No description provided for @snackDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get snackDeleted;

  /// No description provided for @permissionCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan'**
  String get permissionCameraDenied;
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
      <String>['en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
