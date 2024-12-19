import 'package:deep_track_cli/models/file_analyzer.dart';

class FileMapMindAnalyzer extends FileAnalyzer {
  bool isExternalFile;

  FileMapMindAnalyzer({
    required super.path,
    required super.nameFile,
    required super.imports,
    required super.references,
    this.isExternalFile = false,
  });

  @override
  String toString() {
    return 'FileMapMindAnalyzer(path: $path, nameFile: $nameFile, imports: $imports, references: $references, isExternalFile: $isExternalFile)';
  }

  factory FileMapMindAnalyzer.external({
    required String path,
    required String nameFile,
    List<String>? imports,
    List<String>? references,
  }) {
    return FileMapMindAnalyzer(
      path: path,
      nameFile: nameFile,
      imports: imports,
      references: references,
      isExternalFile: true,
    );
  }
}
