import 'dart:io';

class SearchFilesFilter {
  final String basePath;
  final List<Pattern> patternsFiles;
  final Pattern? imporPattern;

  SearchFilesFilter({
    required this.basePath,
    required this.patternsFiles,
    this.imporPattern,
  });

  Future<List<FileSystemEntity>> getFiles(Directory directory) async {
    final dartFiles = <FileSystemEntity>[];

    await for (var entity in directory.list(recursive: true)) {
      if (entity is File &&
          patternsFiles
              .any((pattern) => pattern.allMatches(entity.path).isNotEmpty)) {
        dartFiles.add(entity);
      }
    }

    return dartFiles;
  }
}
