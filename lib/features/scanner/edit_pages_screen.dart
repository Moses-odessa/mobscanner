import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/document_repository.dart';
import '../../l10n/app_localizations.dart';
import 'data/scan_service.dart';

/// Review screen shown after capture/import: pick a filter, reorder or drop
/// pages, then save as a new document (or append to an existing one).
class EditPagesScreen extends ConsumerStatefulWidget {
  const EditPagesScreen({super.key, required this.args});
  final EditPagesArgs args;

  @override
  ConsumerState<EditPagesScreen> createState() => _EditPagesScreenState();
}

class _EditPagesScreenState extends ConsumerState<EditPagesScreen> {
  late List<PageInput> _originals;
  late List<PageInput> _current;
  ScanFilter _filter = ScanFilter.original;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _originals = List.of(widget.args.pageInputs);
    _current = List.of(widget.args.pageInputs);
  }

  Future<void> _applyFilter(ScanFilter filter) async {
    setState(() => _busy = true);
    const service = ScanService();
    final quality = ref.read(settingsProvider).scanQuality;
    final updated = <PageInput>[];
    for (final original in _originals) {
      updated.add(await service.processBytes(
        original.imageBytes,
        filter: filter,
        quality: quality,
      ));
    }
    if (!mounted) return;
    setState(() {
      _filter = filter;
      _current = updated;
      _busy = false;
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = ref.read(documentRepositoryProvider);
    if (widget.args.existingDocumentId != null) {
      await repo.addPages(widget.args.existingDocumentId!, _current);
      if (mounted) context.pop();
    } else {
      final l10n = AppLocalizations.of(context);
      final title = l10n.documentDefaultTitle(
          DateFormat.yMMMd(l10n.localeName).add_Hm().format(DateTime.now()));
      final id = await repo.createDocument(title: title, pages: _current);
      if (mounted) {
        context.pop();
        context.push('/doc/$id');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.actionScan),
        actions: [
          TextButton(
            onPressed: _busy || _current.isEmpty ? null : _save,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _current.isEmpty
                ? Center(child: Text(l10n.libraryEmptyTitle))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _current.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        _current.insert(newIndex, _current.removeAt(oldIndex));
                        _originals.insert(
                            newIndex, _originals.removeAt(oldIndex));
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = _current[index];
                      return Card(
                        key: ValueKey(index),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: SizedBox(
                            width: 56,
                            height: 72,
                            child: Image.memory(
                              page.thumbBytes ?? page.imageBytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text('${l10n.pagesLabel(1)} ${index + 1}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => setState(() {
                              _current.removeAt(index);
                              _originals.removeAt(index);
                            }),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_busy) const LinearProgressIndicator(),
          _FilterBar(
            selected: _filter,
            onSelected: _busy ? null : _applyFilter,
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});
  final ScanFilter selected;
  final ValueChanged<ScanFilter>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      ScanFilter.original: l10n.filterOriginal,
      ScanFilter.grayscale: l10n.filterGrayscale,
      ScanFilter.blackWhite: l10n.filterBlackWhite,
      ScanFilter.magic: l10n.filterMagic,
    };
    return SafeArea(
      top: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (final filter in ScanFilter.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(labels[filter]!),
                  selected: selected == filter,
                  onSelected:
                      onSelected == null ? null : (_) => onSelected!(filter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
