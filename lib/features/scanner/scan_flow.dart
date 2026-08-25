import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/document_repository.dart';
import 'data/scan_service.dart';

/// Coordinates the capture → process → review pipeline and routes into the
/// edit-pages screen. Shared by the FAB, the "add page" action, etc.
class ScanFlow {
  const ScanFlow(this.ref);
  final WidgetRef ref;

  Future<void> startNativeScan(BuildContext context, {String? existingDocumentId}) async {
    const service = ScanService();
    final paths = await service.captureWithNativeScanner();
    if (paths.isEmpty || !context.mounted) return;
    await _processAndReview(context, paths, existingDocumentId: existingDocumentId);
  }

  Future<void> startImport(BuildContext context, {String? existingDocumentId}) async {
    const service = ScanService();
    final paths = await service.importFromGallery();
    if (paths.isEmpty || !context.mounted) return;
    await _processAndReview(context, paths, existingDocumentId: existingDocumentId);
  }

  Future<void> _processAndReview(
    BuildContext context,
    List<String> paths, {
    String? existingDocumentId,
  }) async {
    final quality = ref.read(settingsProvider).scanQuality;
    const service = ScanService();

    _showProcessing(context);
    final inputs = <PageInput>[];
    for (final path in paths) {
      inputs.add(await service.processPath(
        path,
        filter: ScanFilter.original,
        quality: quality,
      ));
    }
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    if (!context.mounted) return;
    await context.push(
      '/edit',
      extra: EditPagesArgs(
        pageInputs: inputs,
        existingDocumentId: existingDocumentId,
      ),
    );
  }

  void _showProcessing(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
