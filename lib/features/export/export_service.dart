import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/constants.dart';
import '../../data/document_repository.dart';
import '../../data/storage/file_storage.dart';

/// Builds shareable artifacts (PDF / TXT / JPG) from a document and hands them
/// to the OS share sheet. Everything is produced locally on device.
class ExportService {
  ExportService(this._storage);

  final FileStorage _storage;

  pw.Font? _unicodeFont;

  /// Unicode font (bundled NotoSans) so the OCR text layer supports Cyrillic
  /// and other non-Latin scripts that the built-in PDF fonts cannot encode.
  Future<pw.Font> _loadUnicodeFont() async {
    return _unicodeFont ??=
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
  }

  Future<File> buildPdf(DocumentWithPages doc) async {
    final pdf = pw.Document(title: doc.document.title);
    final hasOcr =
        doc.pages.any((p) => p.ocrText != null && p.ocrText!.isNotEmpty);
    final font = hasOcr ? await _loadUnicodeFont() : null;
    for (final page in doc.pages) {
      final bytes = await File(page.imagePath).readAsBytes();
      final image = pw.MemoryImage(bytes);
      final ocrText = page.ocrText;
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.Stack(
            children: [
              // Invisible OCR text layer underneath the image makes the PDF
              // searchable and its text selectable/copyable in viewers.
              if (ocrText != null && ocrText.isNotEmpty)
                pw.Positioned.fill(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(16),
                    child: pw.Text(
                      ocrText,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 6,
                        color: const PdfColor(1, 1, 1, 0), // fully transparent
                      ),
                    ),
                  ),
                ),
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final file = File(await _storage.exportFilePath('${_safe(doc.document.title)}.pdf'));
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  Future<File> buildText(DocumentWithPages doc) async {
    final buffer = StringBuffer();
    for (var i = 0; i < doc.pages.length; i++) {
      final text = doc.pages[i].ocrText;
      if (text != null && text.isNotEmpty) {
        if (i > 0) buffer.writeln('\n\n');
        buffer.writeln(text);
      }
    }
    final file = File(await _storage.exportFilePath('${_safe(doc.document.title)}.txt'));
    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  Future<List<File>> buildImages(DocumentWithPages doc) async {
    final files = <File>[];
    for (var i = 0; i < doc.pages.length; i++) {
      final src = File(doc.pages[i].imagePath);
      final out = File(await _storage
          .exportFilePath('${_safe(doc.document.title)}_${i + 1}.jpg'));
      await out.writeAsBytes(await src.readAsBytes(), flush: true);
      files.add(out);
    }
    return files;
  }

  Future<File> export(DocumentWithPages doc, ExportFormat format) async {
    switch (format) {
      case ExportFormat.pdf:
        return buildPdf(doc);
      case ExportFormat.txt:
        return buildText(doc);
      case ExportFormat.jpg:
        return (await buildImages(doc)).first;
    }
  }

  Future<void> share(DocumentWithPages doc, ExportFormat format) async {
    final List<XFile> files;
    if (format == ExportFormat.jpg) {
      files = (await buildImages(doc)).map((f) => XFile(f.path)).toList();
    } else {
      files = [XFile((await export(doc, format)).path)];
    }
    await Share.shareXFiles(files, subject: doc.document.title);
  }

  /// Raw PDF bytes for printing via the `printing` package.
  Future<Uint8List> pdfBytes(DocumentWithPages doc) async {
    final file = await buildPdf(doc);
    return file.readAsBytes();
  }

  String _safe(String name) =>
      name.replaceAll(RegExp(r'[^\w\s.-]'), '_').trim().isEmpty
          ? 'document'
          : name.replaceAll(RegExp(r'[^\w\s.-]'), '_').trim();
}
