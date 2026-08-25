// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MobScanner';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navScan => 'Скан';

  @override
  String get navSettings => 'Настройки';

  @override
  String get libraryEmptyTitle => 'Пока нет документов';

  @override
  String get libraryEmptySubtitle =>
      'Нажмите «Скан», чтобы отсканировать первый документ';

  @override
  String get libraryTitle => 'Мои документы';

  @override
  String get searchHint => 'Поиск по документам и тексту';

  @override
  String get actionScan => 'Скан';

  @override
  String get actionImport => 'Импорт';

  @override
  String get actionRename => 'Переименовать';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionMove => 'Переместить';

  @override
  String get actionShare => 'Поделиться';

  @override
  String get actionExportPdf => 'Экспорт в PDF';

  @override
  String get actionExportText => 'Экспорт текста';

  @override
  String get actionRunOcr => 'Распознать текст (OCR)';

  @override
  String get actionAddPage => 'Добавить страницу';

  @override
  String get actionRotate => 'Повернуть';

  @override
  String get actionCrop => 'Обрезать';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionNewFolder => 'Новая папка';

  @override
  String get filterOriginal => 'Оригинал';

  @override
  String get filterGrayscale => 'Ч/б градации';

  @override
  String get filterBlackWhite => 'Ч/б';

  @override
  String get filterMagic => 'Magic color';

  @override
  String get dialogRenameTitle => 'Переименовать документ';

  @override
  String get dialogDeleteTitle => 'Удалить документ?';

  @override
  String get dialogDeleteMessage => 'Это действие нельзя отменить.';

  @override
  String get dialogNewFolderTitle => 'Название новой папки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык приложения';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsOcrLanguages => 'Языки OCR';

  @override
  String get settingsScanQuality => 'Качество сканов';

  @override
  String get settingsExportFormat => 'Формат экспорта по умолчанию';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get qualityLow => 'Низкое';

  @override
  String get qualityMedium => 'Среднее';

  @override
  String get qualityHigh => 'Высокое';

  @override
  String get ocrRunning => 'Распознавание текста…';

  @override
  String get ocrDone => 'Текст распознан';

  @override
  String get ocrNoText => 'Текст не найден';

  @override
  String pagesLabel(int count) {
    return '$count стр.';
  }

  @override
  String documentDefaultTitle(String date) {
    return 'Скан $date';
  }

  @override
  String get folderAll => 'Все документы';

  @override
  String get snackExported => 'Успешно экспортировано';

  @override
  String get snackDeleted => 'Удалено';

  @override
  String get permissionCameraDenied => 'Для сканирования нужен доступ к камере';
}
