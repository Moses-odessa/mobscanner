import 'dart:io';

import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

import '../../core/constants.dart';

/// Offline OCR wrapper.
///
/// On Android this runs Tesseract against the `.traineddata` models bundled
/// under `assets/tessdata/` (listed in `assets/tessdata_config.json`). On iOS
/// the plugin uses Apple's Vision framework, which recognizes Cyrillic
/// natively and is both faster and more accurate than Tesseract there.
///
/// Either way recognition happens entirely on device — no network involved.
class OcrService {
  const OcrService();

  /// Recognize text in the image at [imagePath] using the given [languages].
  ///
  /// Tesseract accepts several languages joined with '+', e.g. `rus+eng`.
  Future<String> recognize(
    String imagePath, {
    List<OcrLanguage> languages = const [OcrLanguage.eng],
  }) async {
    final selected = languages.isEmpty ? [OcrLanguage.eng] : languages;
    final config = OCRConfig(
      language: selected.map((l) => l.code).join('+'),
      // Vision on iOS, Tesseract on Android — the plugin picks per platform.
      engine: Platform.isIOS ? OCREngine.vision : OCREngine.tesseract,
      options: const {
        TesseractConfig.preserveInterwordSpaces: '1',
      },
    );
    final text = await TesseractOcr.extractText(imagePath, config: config);
    return text.trim();
  }
}
