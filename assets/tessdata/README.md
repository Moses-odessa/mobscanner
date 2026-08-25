# Tesseract traineddata

The OCR feature uses [Tesseract](https://github.com/tesseract-ocr/tesseract)
offline. Place the language model files here (they are large binary files and
are **not** committed to git):

- `eng.traineddata`
- `rus.traineddata`
- `ukr.traineddata`

Download the `best` or `fast` models from the official repository:

- Fast (smaller, recommended for mobile):
  https://github.com/tesseract-ocr/tessdata_fast
- Best (higher accuracy, larger):
  https://github.com/tesseract-ocr/tessdata_best

Example (from the project root):

```bash
cd assets/tessdata
curl -LO https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata
curl -LO https://github.com/tesseract-ocr/tessdata_fast/raw/main/rus.traineddata
curl -LO https://github.com/tesseract-ocr/tessdata_fast/raw/main/ukr.traineddata
```

The `tesseract_ocr` plugin loads these bundled assets at runtime on Android.
The file list must also be mirrored in `assets/tessdata_config.json`.

On **iOS** the plugin uses Apple's Vision framework instead, which recognizes
Russian and Ukrainian natively — no traineddata needed there.

After adding files, run `flutter pub get` and rebuild.
