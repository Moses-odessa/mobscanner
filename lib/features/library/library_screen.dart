import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/document_repository.dart';
import '../../l10n/app_localizations.dart';

/// Grid of scanned documents with search and folder filtering.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final docsAsync = query.trim().isEmpty
        ? ref.watch(documentsProvider)
        : ref.watch(searchResultsProvider).whenData((v) => v ?? const []);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
            ),
            onChanged: (v) =>
                ref.read(searchQueryProvider.notifier).state = v,
          ),
        ),
        const _FolderChips(),
        Expanded(
          child: docsAsync.when(
            data: (docs) => docs.isEmpty
                ? _EmptyState(l10n: l10n)
                : _DocumentGrid(docs: docs),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
        ),
      ],
    );
  }
}

class _FolderChips extends ConsumerWidget {
  const _FolderChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final folders = ref.watch(foldersProvider);
    final selected = ref.watch(selectedFolderProvider);

    return folders.maybeWhen(
      data: (list) => SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(l10n.folderAll),
                selected: selected == null,
                onSelected: (_) =>
                    ref.read(selectedFolderProvider.notifier).state = null,
              ),
            ),
            for (final f in list)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(f.name),
                  selected: selected == f.id,
                  onSelected: (_) =>
                      ref.read(selectedFolderProvider.notifier).state = f.id,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                avatar: const Icon(Icons.create_new_folder_outlined, size: 18),
                label: Text(l10n.actionNewFolder),
                onPressed: () => _createFolder(context, ref, l10n),
              ),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox(height: 44),
    );
  }

  Future<void> _createFolder(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogNewFolderTitle),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(documentRepositoryProvider).createFolder(name);
    }
  }
}

class _DocumentGrid extends StatelessWidget {
  const _DocumentGrid({required this.docs});
  final List<DocumentWithPages> docs;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return _DocumentCard(doc: doc, dateLabel: dateFmt.format(doc.document.updatedAt));
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc, required this.dateLabel});
  final DocumentWithPages doc;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final thumbPath = doc.firstPage?.thumbPath ?? doc.firstPage?.imagePath;
    return Card(
      child: InkWell(
        onTap: () => context.push('/doc/${doc.document.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: thumbPath != null
                  ? Image.file(File(thumbPath), fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ThumbFallback())
                  : const _ThumbFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dateLabel · ${l10n.pagesLabel(doc.pageCount)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();
  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.description_outlined, size: 40)),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.libraryEmptyTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.libraryEmptySubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
