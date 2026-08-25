import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobscanner/data/db/database.dart';
import 'package:mobscanner/data/document_repository.dart';
import 'package:mobscanner/data/storage/file_storage.dart';

/// In-memory FileStorage stub so repository tests never touch the real disk.
class _FakeStorage implements FileStorage {
  @override
  Future<String> savePageImage(String pageId, Uint8List bytes) async =>
      '/pages/$pageId.jpg';
  @override
  Future<String> saveThumb(String pageId, Uint8List bytes) async =>
      '/thumbs/$pageId.jpg';
  @override
  Future<String> exportFilePath(String filename) async => '/exports/$filename';
  @override
  Future<void> deleteFiles(Iterable<String?> paths) async {}
}

void main() {
  late AppDatabase db;
  late DocumentRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DocumentRepository(db, _FakeStorage());
  });

  tearDown(() => db.close());

  PageInput page() => PageInput(imageBytes: Uint8List.fromList([1, 2, 3]));

  test('create and fetch a document with pages', () async {
    final id = await repo.createDocument(title: 'Test', pages: [page(), page()]);
    final doc = await repo.getDocument(id);
    expect(doc, isNotNull);
    expect(doc!.pageCount, 2);
    expect(doc.document.title, 'Test');
  });

  test('rename updates the title', () async {
    final id = await repo.createDocument(title: 'Old', pages: [page()]);
    await repo.renameDocument(id, 'New');
    final doc = await repo.getDocument(id);
    expect(doc!.document.title, 'New');
  });

  test('search matches OCR text', () async {
    final id = await repo.createDocument(title: 'Untitled', pages: [page()]);
    final doc = await repo.getDocument(id);
    await repo.setPageOcr(doc!.pages.first.id, 'hello invoice world');
    final results = await repo.search('invoice');
    expect(results.length, 1);
    expect(results.first.document.id, id);
  });

  test('delete removes the document', () async {
    final id = await repo.createDocument(title: 'X', pages: [page()]);
    await repo.deleteDocument(id);
    expect(await repo.getDocument(id), isNull);
  });
}
