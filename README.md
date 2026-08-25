# MobScanner

A free, **local-first**, cross-platform document scanner — a privacy-respecting
alternative to CamScanner. Built with Flutter. All scanning, OCR and storage
happen **on device**; there are no servers and no accounts.

## Features (MVP)

- 📷 **Scan** documents with automatic edge detection & perspective correction
  (native ML Kit / VisionKit scanner) plus import from gallery.
- 🎨 **Filters**: Original, Grayscale, Black & White (adaptive threshold),
  Magic Color.
- 📄 **Multi-page documents**: reorder, add and delete pages.
- 🔤 **OCR** (offline, multilingual incl. Cyrillic): Tesseract on Android,
  Apple Vision on iOS.
- 🗂 **Organize**: folders, rename, full-text search over titles and OCR text.
- 📤 **Export & share**: PDF, JPG, TXT, and system print — all local.
- 🌗 Light/dark themes, and EN / RU / UK localization.

## Tech stack

Flutter · Riverpod · go_router · drift (SQLite) · image · pdf/printing ·
tesseract_ocr · cunning_document_scanner · share_plus.

### Vendored OCR plugin

`tesseract_ocr` is vendored under [`packages/tesseract_ocr`](packages/tesseract_ocr)
rather than pulled from pub.dev. Upstream declares the shut-down `jcenter()`
repository, which Gradle 9 removed outright, and ships a Kotlin stub that
collides with its own Java implementation under AGP 9's built-in Kotlin. The
vendored copy is source-only (~205 KB, no binaries — `tesseract4android` comes
from Maven Central); every local change is documented at the top of
[`android/build.gradle`](packages/tesseract_ocr/android/build.gradle).

See the architecture overview in `lib/` (feature-first: `core`, `data`,
`features/{scanner,editor,ocr,library,export,settings}`).

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift + codegen
flutter gen-l10n                                            # localizations
flutter run
```

### OCR models

OCR needs Tesseract traineddata files in `assets/tessdata/`
(`eng`, `rus`, `ukr`). They are large binaries and are not committed — see
[`assets/tessdata/README.md`](assets/tessdata/README.md) for download commands.

## Platforms

MVP targets **Android** and **iOS**. The project is also scaffolded for web,
Windows, macOS and Linux; the domain/data layers are platform-agnostic, and the
scanner/OCR are isolated behind services for future desktop/web support.

## Testing

```bash
flutter analyze
flutter test
```

## Roadmap

- Manual corner-crop editor (pure-Dart perspective warp already implemented).
- Searchable PDF (text layer) export.
- Optional cloud sync (E2E-encrypted; user's own Drive/Dropbox).
- QR/barcode, signatures, watermarks, batch & ID-card modes.
- opencv_dart pipeline as an optional performance/accuracy upgrade.

## License

Intended to be released as free & open-source.
