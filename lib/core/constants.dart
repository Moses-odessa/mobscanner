/// App-wide constants and enums shared across features.
library;

/// Image filter applied to a scanned page.
enum ScanFilter { original, grayscale, blackWhite, magic }

/// Scan capture / export quality preset. Values map to JPEG quality and max
/// dimension used when persisting page images.
enum ScanQuality {
  low(quality: 60, maxDimension: 1240),
  medium(quality: 80, maxDimension: 2000),
  high(quality: 92, maxDimension: 3000);

  const ScanQuality({required this.quality, required this.maxDimension});

  final int quality;
  final int maxDimension;
}

/// Default export format when the user shares/exports a document.
enum ExportFormat { pdf, jpg, txt }

/// OCR languages bundled with the app (Tesseract traineddata codes).
class OcrLanguage {
  const OcrLanguage(this.code, this.label);
  final String code;
  final String label;

  static const eng = OcrLanguage('eng', 'English');
  static const rus = OcrLanguage('rus', 'Русский');
  static const ukr = OcrLanguage('ukr', 'Українська');

  static const all = [eng, rus, ukr];
}

/// Storage sub-directory names inside the app documents directory.
class StoragePaths {
  static const pages = 'pages';
  static const thumbs = 'thumbs';
  static const exports = 'exports';
}

/// SharedPreferences keys for persisted settings.
class PrefKeys {
  static const themeMode = 'settings.themeMode';
  static const locale = 'settings.locale';
  static const ocrLanguages = 'settings.ocrLanguages';
  static const scanQuality = 'settings.scanQuality';
  static const exportFormat = 'settings.exportFormat';
  static const onboardingDone = 'onboarding.done';
}
