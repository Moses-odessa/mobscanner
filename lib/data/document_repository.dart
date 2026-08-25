import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/database.dart';
import 'storage/file_storage.dart';

const _uuid = Uuid();

/// A document together with its ordered pages — the aggregate the UI works with.
class DocumentWithPages {
  DocumentWithPages(this.document, this.pages);
  final Document document;
  final List<Page> pages;

  Page? get firstPage => pages.isEmpty ? null : pages.first;
  int get pageCount => pages.length;
}

/// High-level data access facade over drift + file storage. All persistence
/// goes through here so features never touch the database or filesystem
/// directly.
class DocumentRepository {
  DocumentRepository(this._db, this._storage);

  final AppDatabase _db;
  final FileStorage _storage;

  // ---- Folders ------------------------------------------------------------

  Stream<List<Folder>> watchFolders() =>
      (_db.select(_db.folders)..orderBy([(f) => OrderingTerm(expression: f.name)]))
          .watch();

  Future<Folder> createFolder(String name, {String? parentId}) async {
    final folder = Folder(
      id: _uuid.v4(),
      name: name,
      parentId: parentId,
      createdAt: DateTime.now(),
    );
    await _db.into(_db.folders).insert(folder);
    return folder;
  }

  Future<void> deleteFolder(String id) async {
    await (_db.update(_db.documents)..where((d) => d.folderId.equals(id)))
        .write(const DocumentsCompanion(folderId: Value(null)));
    await (_db.delete(_db.folders)..where((f) => f.id.equals(id))).go();
  }

  // ---- Documents ----------------------------------------------------------

  /// Watch documents in a folder (null = all documents), newest first.
  Stream<List<DocumentWithPages>> watchDocuments({String? folderId}) {
    final query = _db.select(_db.documents)
      ..orderBy([(d) => OrderingTerm(expression: d.updatedAt, mode: OrderingMode.desc)]);
    if (folderId != null) {
      query.where((d) => d.folderId.equals(folderId));
    }
    return query.watch().asyncMap(_attachPages);
  }

  Future<List<DocumentWithPages>> _attachPages(List<Document> docs) async {
    final result = <DocumentWithPages>[];
    for (final doc in docs) {
      final pages = await (_db.select(_db.pages)
            ..where((p) => p.documentId.equals(doc.id))
            ..orderBy([(p) => OrderingTerm(expression: p.order)]))
          .get();
      result.add(DocumentWithPages(doc, pages));
    }
    return result;
  }

  Future<DocumentWithPages?> getDocument(String id) async {
    final doc = await (_db.select(_db.documents)..where((d) => d.id.equals(id)))
        .getSingleOrNull();
    if (doc == null) return null;
    final withPages = await _attachPages([doc]);
    return withPages.first;
  }

  Stream<DocumentWithPages?> watchDocument(String id) {
    return (_db.select(_db.documents)..where((d) => d.id.equals(id)))
        .watchSingleOrNull()
        .asyncMap((doc) async {
      if (doc == null) return null;
      return (await _attachPages([doc])).first;
    });
  }

  /// Create a new document from a list of already-processed page image bytes.
  Future<String> createDocument({
    required String title,
    required List<PageInput> pages,
    String? folderId,
  }) async {
    final now = DateTime.now();
    final docId = _uuid.v4();
    await _db.into(_db.documents).insert(Document(
          id: docId,
          title: title,
          folderId: folderId,
          createdAt: now,
          updatedAt: now,
        ));
    await _insertPages(docId, pages, startOrder: 0);
    return docId;
  }

  Future<void> addPages(String documentId, List<PageInput> pages) async {
    final existing = await (_db.select(_db.pages)
          ..where((p) => p.documentId.equals(documentId)))
        .get();
    final startOrder = existing.length;
    await _insertPages(documentId, pages, startOrder: startOrder);
    await _touch(documentId);
  }

  Future<void> _insertPages(
    String documentId,
    List<PageInput> pages, {
    required int startOrder,
  }) async {
    for (var i = 0; i < pages.length; i++) {
      final input = pages[i];
      final pageId = _uuid.v4();
      final imagePath = await _storage.savePageImage(pageId, input.imageBytes);
      String? thumbPath;
      if (input.thumbBytes != null) {
        thumbPath = await _storage.saveThumb(pageId, input.thumbBytes!);
      }
      await _db.into(_db.pages).insert(Page(
            id: pageId,
            documentId: documentId,
            order: startOrder + i,
            imagePath: imagePath,
            thumbPath: thumbPath,
            ocrText: null,
            width: input.width,
            height: input.height,
          ));
    }
  }

  Future<void> replacePageImage(String pageId, PageInput input) async {
    final imagePath = await _storage.savePageImage(pageId, input.imageBytes);
    String? thumbPath;
    if (input.thumbBytes != null) {
      thumbPath = await _storage.saveThumb(pageId, input.thumbBytes!);
    }
    await (_db.update(_db.pages)..where((p) => p.id.equals(pageId))).write(
      PagesCompanion(
        imagePath: Value(imagePath),
        thumbPath: Value(thumbPath),
        width: Value(input.width),
        height: Value(input.height),
      ),
    );
  }

  Future<void> reorderPages(String documentId, List<String> orderedPageIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedPageIds.length; i++) {
        await (_db.update(_db.pages)..where((p) => p.id.equals(orderedPageIds[i])))
            .write(PagesCompanion(order: Value(i)));
      }
    });
    await _touch(documentId);
  }

  Future<void> deletePage(String pageId) async {
    final page =
        await (_db.select(_db.pages)..where((p) => p.id.equals(pageId)))
            .getSingleOrNull();
    if (page == null) return;
    await (_db.delete(_db.pages)..where((p) => p.id.equals(pageId))).go();
    await _storage.deleteFiles([page.imagePath, page.thumbPath]);
    await _touch(page.documentId);
  }

  Future<void> setPageOcr(String pageId, String text) async {
    await (_db.update(_db.pages)..where((p) => p.id.equals(pageId)))
        .write(PagesCompanion(ocrText: Value(text)));
  }

  Future<void> renameDocument(String id, String title) async {
    await (_db.update(_db.documents)..where((d) => d.id.equals(id)))
        .write(DocumentsCompanion(title: Value(title), updatedAt: Value(DateTime.now())));
  }

  Future<void> moveDocument(String id, String? folderId) async {
    await (_db.update(_db.documents)..where((d) => d.id.equals(id)))
        .write(DocumentsCompanion(folderId: Value(folderId), updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteDocument(String id) async {
    final pages =
        await (_db.select(_db.pages)..where((p) => p.documentId.equals(id))).get();
    await (_db.delete(_db.pages)..where((p) => p.documentId.equals(id))).go();
    await (_db.delete(_db.documentTags)..where((t) => t.documentId.equals(id))).go();
    await (_db.delete(_db.documents)..where((d) => d.id.equals(id))).go();
    await _storage.deleteFiles(pages.expand((p) => [p.imagePath, p.thumbPath]));
  }

  /// Full-text-ish search across document titles and recognized page text.
  Future<List<DocumentWithPages>> search(String term) async {
    final like = '%${term.trim()}%';
    final byTitle = await (_db.select(_db.documents)
          ..where((d) => d.title.like(like)))
        .get();
    final matchedIds = byTitle.map((d) => d.id).toSet();

    final pageMatches = await (_db.select(_db.pages)
          ..where((p) => p.ocrText.like(like)))
        .get();
    matchedIds.addAll(pageMatches.map((p) => p.documentId));

    if (matchedIds.isEmpty) return [];
    final docs = await (_db.select(_db.documents)
          ..where((d) => d.id.isIn(matchedIds))
          ..orderBy([(d) => OrderingTerm(expression: d.updatedAt, mode: OrderingMode.desc)]))
        .get();
    return _attachPages(docs);
  }

  Future<void> _touch(String documentId) async {
    await (_db.update(_db.documents)..where((d) => d.id.equals(documentId)))
        .write(DocumentsCompanion(updatedAt: Value(DateTime.now())));
  }
}

/// A page ready to be persisted: final image + optional thumbnail + dimensions.
class PageInput {
  PageInput({
    required this.imageBytes,
    this.thumbBytes,
    this.width = 0,
    this.height = 0,
  });

  final Uint8List imageBytes;
  final Uint8List? thumbBytes;
  final int width;
  final int height;
}
