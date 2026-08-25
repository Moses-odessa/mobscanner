import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants.dart';
import '../../../data/document_repository.dart';
import 'image_processor.dart';

/// Parameters passed to the isolate that processes one captured frame.
class _ProcessArgs {
  _ProcessArgs(this.bytes, this.filter, this.maxDimension, this.quality);
  final Uint8List bytes;
  final ScanFilter filter;
  final int maxDimension;
  final int quality;
}

/// Runs on a background isolate via [compute]: decode → downscale → filter →
/// encode main image + thumbnail. Keeps the UI thread responsive.
PageInput _processFrame(_ProcessArgs args) {
  const processor = ImageProcessor();
  var image = processor.decode(args.bytes);
  image = processor.clampSize(image, args.maxDimension);
  final filtered = processor.applyFilter(image, args.filter);
  final mainBytes = processor.encodeJpg(filtered, quality: args.quality);
  final thumb = processor.makeThumbnail(filtered);
  final thumbBytes = processor.encodeJpg(thumb, quality: 70);
  return PageInput(
    imageBytes: mainBytes,
    thumbBytes: thumbBytes,
    width: filtered.width,
    height: filtered.height,
  );
}

/// Orchestrates document capture and turns raw frames into persistable pages.
class ScanService {
  const ScanService();

  /// Launch the native document scanner (ML Kit on Android, VisionKit on iOS),
  /// which performs edge detection & perspective correction, and returns the
  /// captured page image file paths.
  Future<List<String>> captureWithNativeScanner() async {
    final pictures = await CunningDocumentScanner.getPictures() ?? const [];
    return pictures;
  }

  /// Pick one or more existing images from the gallery to import as pages.
  Future<List<String>> importFromGallery() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    return files.map((f) => f.path).toList();
  }

  Future<PageInput> processPath(
    String path, {
    required ScanFilter filter,
    required ScanQuality quality,
  }) async {
    final bytes = await File(path).readAsBytes();
    return processBytes(bytes, filter: filter, quality: quality);
  }

  Future<PageInput> processBytes(
    Uint8List bytes, {
    required ScanFilter filter,
    required ScanQuality quality,
  }) {
    return compute(
      _processFrame,
      _ProcessArgs(bytes, filter, quality.maxDimension, quality.quality),
    );
  }

  /// Re-encode an [img.Image] the editor produced (already warped) into a page.
  Future<PageInput> finalizeEdited(
    img.Image image, {
    required ScanFilter filter,
    required ScanQuality quality,
  }) async {
    final bytes = Uint8List.fromList(img.encodeJpg(image));
    return processBytes(bytes, filter: filter, quality: quality);
  }
}
