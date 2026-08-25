import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/document_repository.dart';
import '../../l10n/app_localizations.dart';
import '../scanner/scan_flow.dart';

/// Detail view of a single document: page carousel, OCR, export & management.
class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({super.key, required this.documentId});
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final docAsync = ref.watch(documentProvider(documentId));

    return docAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (doc) {
        if (doc == null) {
          return const Scaffold(body: Center(child: Text('—')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(doc.document.title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.text_fields),
                tooltip: l10n.actionRunOcr,
                onPressed: () => _runOcr(context, ref, doc),
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                onPressed: () => _print(ref, doc),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _onMenu(context, ref, doc, value, l10n),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'share', child: Text(l10n.actionShare)),
                  PopupMenuItem(
                      value: 'pdf', child: Text(l10n.actionExportPdf)),
                  PopupMenuItem(
                      value: 'txt', child: Text(l10n.actionExportText)),
                  PopupMenuItem(
                      value: 'addPage', child: Text(l10n.actionAddPage)),
                  PopupMenuItem(
                      value: 'rename', child: Text(l10n.actionRename)),
                  PopupMenuItem(
                      value: 'delete', child: Text(l10n.actionDelete)),
                ],
              ),
            ],
          ),
          body: _PageCarousel(doc: doc),
        );
      },
    );
  }

  Future<void> _onMenu(BuildContext context, WidgetRef ref,
      DocumentWithPages doc, String value, AppLocalizations l10n) async {
    final exporter = ref.read(exportServiceProvider);
    switch (value) {
      case 'share':
        await exporter.share(doc, ref.read(settingsProvider).exportFormat);
      case 'pdf':
        await exporter.share(doc, ExportFormat.pdf);
        if (context.mounted) _toast(context, l10n.snackExported);
      case 'txt':
        await exporter.share(doc, ExportFormat.txt);
        if (context.mounted) _toast(context, l10n.snackExported);
      case 'addPage':
        await ScanFlow(ref)
            .startNativeScan(context, existingDocumentId: doc.document.id);
      case 'rename':
        await _rename(context, ref, doc, l10n);
      case 'delete':
        await _delete(context, ref, doc, l10n);
    }
  }

  Future<void> _runOcr(
      BuildContext context, WidgetRef ref, DocumentWithPages doc) async {
    final l10n = AppLocalizations.of(context);
    final ocr = ref.read(ocrServiceProvider);
    final repo = ref.read(documentRepositoryProvider);
    final languages = ref.read(settingsProvider).ocrLanguages;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.ocrRunning)));
    var found = false;
    for (final page in doc.pages) {
      try {
        final text = await ocr.recognize(page.imagePath, languages: languages);
        if (text.isNotEmpty) found = true;
        await repo.setPageOcr(page.id, text);
      } catch (_) {
        // Keep going through remaining pages on per-page failures.
      }
    }
    messenger.showSnackBar(
        SnackBar(content: Text(found ? l10n.ocrDone : l10n.ocrNoText)));
  }

  Future<void> _print(WidgetRef ref, DocumentWithPages doc) async {
    final exporter = ref.read(exportServiceProvider);
    final bytes = await exporter.pdfBytes(doc);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _rename(BuildContext context, WidgetRef ref,
      DocumentWithPages doc, AppLocalizations l10n) async {
    final controller = TextEditingController(text: doc.document.title);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogRenameTitle),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.actionSave)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(documentRepositoryProvider).renameDocument(doc.document.id, name);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref,
      DocumentWithPages doc, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogDeleteTitle),
        content: Text(l10n.dialogDeleteMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.actionDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(documentRepositoryProvider).deleteDocument(doc.document.id);
      if (context.mounted) context.pop();
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PageCarousel extends ConsumerStatefulWidget {
  const _PageCarousel({required this.doc});
  final DocumentWithPages doc;

  @override
  ConsumerState<_PageCarousel> createState() => _PageCarouselState();
}

class _PageCarouselState extends ConsumerState<_PageCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = widget.doc.pages;
    if (pages.isEmpty) {
      return Center(child: Text(l10n.libraryEmptyTitle));
    }
    final current = pages[_page.clamp(0, pages.length - 1)];
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.file(File(pages[index].imagePath)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('${_page + 1} / ${pages.length}',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        if (current.ocrText != null && current.ocrText!.isNotEmpty)
          _OcrPanel(text: current.ocrText!),
      ],
    );
  }
}

class _OcrPanel extends StatelessWidget {
  const _OcrPanel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: SelectableText(text,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ),
    );
  }
}
