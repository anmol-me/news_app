import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_platform/universal_platform.dart';

const initialAssetFile = 'assets/demo_files/categories.json';
const localFilename = 'categories.json';

enum AssetFileName {
  entries('entries.json'),
  categories('categories.json');

  final String value;

  const AssetFileName(this.value);
}

enum AssetFilePath {
  entries('assets/demo_files/entries.json'),
  categories('assets/demo_files/categories.json');

  final String value;

  const AssetFilePath(this.value);
}

final fileRepositoryProvider = Provider((ref) => FileRepository());

class FileRepository {
  /// Initially check if there is already a local file.
  /// If not, create one with the contents of the initial json in assets
  Future<File> _initializeFile(
    String assetName,
    String path,
  ) async {
    final localDirectory = (await getApplicationDocumentsDirectory()).path;
    final file = File('$localDirectory\\$assetName');

    if (!await file.exists()) {
      // read the file from assets first and create the local file with its contents
      final initialContent = await rootBundle.loadString(path);
      await file.create();
      await file.writeAsString(initialContent);
    }

    return file;
  }

  Future<String> readFile(
    String assetName,
  ) async {
    final String path = _getPath(assetName);

    if (UniversalPlatform.isWeb) {
      return await rootBundle.loadString(path);
    }

    final file = await _initializeFile(assetName, path);
    return await file.readAsString();
  }

  Future<void> writeToFile({
    required String data,
    required String assetName,
  }) async {
    final String path = _getPath(assetName);

    final file = await _initializeFile(assetName, path);
    await file.writeAsString(data);
  }

  String _getPath(String assetName) {
    final String path;
    if (assetName == AssetFileName.entries.value) {
      path = AssetFilePath.entries.value;
    } else if (assetName == AssetFileName.categories.value) {
      path = AssetFilePath.categories.value;
    } else {
      path = '';
    }
    return path;
  }
}
