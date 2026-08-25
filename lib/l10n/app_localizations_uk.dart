// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'MobScanner';

  @override
  String get navLibrary => 'Бібліотека';

  @override
  String get navScan => 'Скан';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get libraryEmptyTitle => 'Ще немає документів';

  @override
  String get libraryEmptySubtitle =>
      'Натисніть «Скан», щоб відсканувати перший документ';

  @override
  String get libraryTitle => 'Мої документи';

  @override
  String get searchHint => 'Пошук за документами та текстом';

  @override
  String get actionScan => 'Скан';

  @override
  String get actionImport => 'Імпорт';

  @override
  String get actionRename => 'Перейменувати';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionMove => 'Перемістити';

  @override
  String get actionShare => 'Поділитися';

  @override
  String get actionExportPdf => 'Експорт у PDF';

  @override
  String get actionExportText => 'Експорт тексту';

  @override
  String get actionRunOcr => 'Розпізнати текст (OCR)';

  @override
  String get actionAddPage => 'Додати сторінку';

  @override
  String get actionRotate => 'Повернути';

  @override
  String get actionCrop => 'Обрізати';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get actionNewFolder => 'Нова папка';

  @override
  String get filterOriginal => 'Оригінал';

  @override
  String get filterGrayscale => 'Відтінки сірого';

  @override
  String get filterBlackWhite => 'Ч/б';

  @override
  String get filterMagic => 'Magic color';

  @override
  String get dialogRenameTitle => 'Перейменувати документ';

  @override
  String get dialogDeleteTitle => 'Видалити документ?';

  @override
  String get dialogDeleteMessage => 'Цю дію не можна скасувати.';

  @override
  String get dialogNewFolderTitle => 'Назва нової папки';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsLanguage => 'Мова застосунку';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsOcrLanguages => 'Мови OCR';

  @override
  String get settingsScanQuality => 'Якість сканів';

  @override
  String get settingsExportFormat => 'Формат експорту за замовчуванням';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String get qualityLow => 'Низька';

  @override
  String get qualityMedium => 'Середня';

  @override
  String get qualityHigh => 'Висока';

  @override
  String get ocrRunning => 'Розпізнавання тексту…';

  @override
  String get ocrDone => 'Текст розпізнано';

  @override
  String get ocrNoText => 'Текст не знайдено';

  @override
  String pagesLabel(int count) {
    return '$count стор.';
  }

  @override
  String documentDefaultTitle(String date) {
    return 'Скан $date';
  }

  @override
  String get folderAll => 'Усі документи';

  @override
  String get snackExported => 'Успішно експортовано';

  @override
  String get snackDeleted => 'Видалено';

  @override
  String get permissionCameraDenied =>
      'Для сканування потрібен доступ до камери';
}
