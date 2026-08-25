import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';

/// Owns the on-disk layout for scanned page images, thumbnails and exports.
///
/// All files live under the app documents directory so they are private to the
/// app and included in normal device backups — no server involved.
///
/// Methods return absolute path strings (not [File]) so the repository stays
/// decoupled from `dart:io` and is trivial to fake in tests.
class FileStorage {
  Directory? _root;

  Future<Directory> _ensureDir(String sub) async {
    _root ??= await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(_root!.path, sub));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> savePageImage(String pageId, Uint8List bytes) async {
    final dir = await _ensureDir(StoragePaths.pages);
    final file = File(p.join(dir.path, '$pageId.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<String> saveThumb(String pageId, Uint8List bytes) async {
    final dir = await _ensureDir(StoragePaths.thumbs);
    final file = File(p.join(dir.path, '$pageId.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Returns the absolute path a to-be-written export file should use.
  Future<String> exportFilePath(String filename) async {
    final dir = await _ensureDir(StoragePaths.exports);
    return p.join(dir.path, filename);
  }

  Future<void> deleteFiles(Iterable<String?> paths) async {
    for (final path in paths) {
      if (path == null) continue;
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {
          // Best-effort cleanup; ignore individual failures.
        }
      }
    }
  }
}
