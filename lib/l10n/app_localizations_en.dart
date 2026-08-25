// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MobScanner';

  @override
  String get navLibrary => 'Library';

  @override
  String get navScan => 'Scan';

  @override
  String get navSettings => 'Settings';

  @override
  String get libraryEmptyTitle => 'No documents yet';

  @override
  String get libraryEmptySubtitle => 'Tap Scan to capture your first document';

  @override
  String get libraryTitle => 'My documents';

  @override
  String get searchHint => 'Search documents and text';

  @override
  String get actionScan => 'Scan';

  @override
  String get actionImport => 'Import';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionMove => 'Move';

  @override
  String get actionShare => 'Share';

  @override
  String get actionExportPdf => 'Export PDF';

  @override
  String get actionExportText => 'Export text';

  @override
  String get actionRunOcr => 'Recognize text (OCR)';

  @override
  String get actionAddPage => 'Add page';

  @override
  String get actionRotate => 'Rotate';

  @override
  String get actionCrop => 'Crop';

  @override
  String get actionDone => 'Done';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionNewFolder => 'New folder';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterGrayscale => 'Grayscale';

  @override
  String get filterBlackWhite => 'B&W';

  @override
  String get filterMagic => 'Magic color';

  @override
  String get dialogRenameTitle => 'Rename document';

  @override
  String get dialogDeleteTitle => 'Delete document?';

  @override
  String get dialogDeleteMessage => 'This action cannot be undone.';

  @override
  String get dialogNewFolderTitle => 'New folder name';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsOcrLanguages => 'OCR languages';

  @override
  String get settingsScanQuality => 'Scan quality';

  @override
  String get settingsExportFormat => 'Default export format';

  @override
  String get settingsAbout => 'About';

  @override
  String get qualityLow => 'Low';

  @override
  String get qualityMedium => 'Medium';

  @override
  String get qualityHigh => 'High';

  @override
  String get ocrRunning => 'Recognizing text…';

  @override
  String get ocrDone => 'Text recognized';

  @override
  String get ocrNoText => 'No text found';

  @override
  String pagesLabel(int count) {
    return '$count pages';
  }

  @override
  String documentDefaultTitle(String date) {
    return 'Scan $date';
  }

  @override
  String get folderAll => 'All documents';

  @override
  String get snackExported => 'Exported successfully';

  @override
  String get snackDeleted => 'Deleted';

  @override
  String get permissionCameraDenied => 'Camera permission is required to scan';
}
