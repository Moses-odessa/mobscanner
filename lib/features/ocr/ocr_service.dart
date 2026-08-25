import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

import '../../core/constants.dart';

/// Offline OCR wrapper around Tesseract.
///
/// Traineddata files (`eng.traineddata`, `rus.traineddata`, `ukr.traineddata`)
/// are bundled under `assets/tessdata/`. The flutter_tesseract_ocr plugin loads
/// them at runtime — no network, fully local.
class OcrService {
  const OcrService();

  /// Recognize text in the image at [imagePath] using the given [languages].
  /// Language codes are joined with '+', e.g. `rus+eng`.
  Future<String> recognize(
    String imagePath, {
    List<OcrLanguage> languages = const [OcrLanguage.eng],
  }) async {
    final lang = (languages.isEmpty ? [OcrLanguage.eng] : languages)
        .map((l) => l.code)
        .join('+');
    final text = await FlutterTesseractOcr.extractText(
      imagePath,
      language: lang,
      args: const {
        'preserve_interword_spaces': '1',
        'psm': '1', // automatic page segmentation with OSD
      },
    );
    return text.trim();
  }
}
