import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Folders form a tree via [parentId] (null = root).
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A scanned document = ordered collection of [Pages].
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get folderId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single page image belonging to a [Documents] row.
class Pages extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text()();
  IntColumn get order => integer()();
  TextColumn get imagePath => text()();
  TextColumn get thumbPath => text().nullable()();
  TextColumn get ocrText => text().nullable()();
  IntColumn get width => integer().withDefault(const Constant(0))();
  IntColumn get height => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class DocumentTags extends Table {
  TextColumn get documentId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {documentId, tagId};
}

@DriftDatabase(tables: [Folders, Documents, Pages, Tags, DocumentTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mobscanner.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
