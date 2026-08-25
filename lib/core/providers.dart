import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/database.dart';
import '../data/document_repository.dart';
import '../data/storage/file_storage.dart';
import '../features/export/export_service.dart';
import '../features/ocr/ocr_service.dart';
import '../features/scanner/data/image_processor.dart';
import 'constants.dart';

/// Injected in [ProviderScope.overrides] at startup once resolved.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final fileStorageProvider = Provider<FileStorage>((ref) => FileStorage());

final imageProcessorProvider =
    Provider<ImageProcessor>((ref) => const ImageProcessor());

final ocrServiceProvider = Provider<OcrService>((ref) => const OcrService());

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(
    ref.watch(databaseProvider),
    ref.watch(fileStorageProvider),
  );
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(fileStorageProvider));
});

// ---- Reactive document streams -------------------------------------------

/// Currently selected folder filter (null = all documents).
final selectedFolderProvider = StateProvider<String?>((ref) => null);

final foldersProvider = StreamProvider((ref) {
  return ref.watch(documentRepositoryProvider).watchFolders();
});

final documentsProvider = StreamProvider((ref) {
  final folderId = ref.watch(selectedFolderProvider);
  return ref.watch(documentRepositoryProvider).watchDocuments(folderId: folderId);
});

final documentProvider = StreamProvider.family((ref, String id) {
  return ref.watch(documentRepositoryProvider).watchDocument(id);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return null;
  return ref.watch(documentRepositoryProvider).search(query);
});

// ---- Settings -------------------------------------------------------------

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.ocrLanguages = const [OcrLanguage.eng],
    this.scanQuality = ScanQuality.medium,
    this.exportFormat = ExportFormat.pdf,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final List<OcrLanguage> ocrLanguages;
  final ScanQuality scanQuality;
  final ExportFormat exportFormat;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    List<OcrLanguage>? ocrLanguages,
    ScanQuality? scanQuality,
    ExportFormat? exportFormat,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      ocrLanguages: ocrLanguages ?? this.ocrLanguages,
      scanQuality: scanQuality ?? this.scanQuality,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static AppSettings _load(SharedPreferences prefs) {
    ThemeMode theme = ThemeMode.values.firstWhere(
      (m) => m.name == prefs.getString(PrefKeys.themeMode),
      orElse: () => ThemeMode.system,
    );
    final localeCode = prefs.getString(PrefKeys.locale);
    final ocrCodes = prefs.getStringList(PrefKeys.ocrLanguages);
    final quality = ScanQuality.values.firstWhere(
      (q) => q.name == prefs.getString(PrefKeys.scanQuality),
      orElse: () => ScanQuality.medium,
    );
    final format = ExportFormat.values.firstWhere(
      (f) => f.name == prefs.getString(PrefKeys.exportFormat),
      orElse: () => ExportFormat.pdf,
    );
    return AppSettings(
      themeMode: theme,
      locale: localeCode == null ? null : Locale(localeCode),
      ocrLanguages: ocrCodes == null
          ? const [OcrLanguage.eng]
          : ocrCodes
              .map((c) => OcrLanguage.all.firstWhere((l) => l.code == c,
                  orElse: () => OcrLanguage.eng))
              .toList(),
      scanQuality: quality,
      exportFormat: format,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(PrefKeys.themeMode, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale, clearLocale: locale == null);
    if (locale == null) {
      await _prefs.remove(PrefKeys.locale);
    } else {
      await _prefs.setString(PrefKeys.locale, locale.languageCode);
    }
  }

  Future<void> setOcrLanguages(List<OcrLanguage> langs) async {
    final value = langs.isEmpty ? [OcrLanguage.eng] : langs;
    state = state.copyWith(ocrLanguages: value);
    await _prefs.setStringList(
        PrefKeys.ocrLanguages, value.map((l) => l.code).toList());
  }

  Future<void> setScanQuality(ScanQuality quality) async {
    state = state.copyWith(scanQuality: quality);
    await _prefs.setString(PrefKeys.scanQuality, quality.name);
  }

  Future<void> setExportFormat(ExportFormat format) async {
    state = state.copyWith(exportFormat: format);
    await _prefs.setString(PrefKeys.exportFormat, format.name);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref.watch(sharedPrefsProvider));
});
