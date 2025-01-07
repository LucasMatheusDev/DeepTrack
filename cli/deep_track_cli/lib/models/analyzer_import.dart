import 'dart:io';

import './file_analyzer.dart';

class AnalyzerImport {
  final List<FileSystemEntity> files;
  final Map<String, FileAnalyzer> fileAnalyzers = {};
  final RegExp importRegex;
  final RegExp exportRegex;

  List<FileAnalyzer> get fileAnalyzersList => fileAnalyzers.values.toList();

  AnalyzerImport(
    this.files, {
    Pattern? importFilterPattern,
    Pattern? exportFilterPattern,
  })  : importRegex = importFilterPattern is RegExp
            ? importFilterPattern
            : RegExp(importFilterPattern?.toString() ??
                r"import\s+'([^']+)';|part\s+'([^']+)';|part of\s+'([^']+)';"),
        exportRegex = exportFilterPattern is RegExp
            ? exportFilterPattern
            : RegExp(exportFilterPattern?.toString() ?? r"export\s+'([^']+)';");

  List<FileAnalyzer> mergeFileAnalyzers(Map<String, FileAnalyzer> other) {
    final Map<String, FileAnalyzer> merged = {...fileAnalyzers, ...other};

    final Set<String> processedReferences = {};

    for (var analyzer in merged.values) {
      for (var reference in analyzer.references) {
        if (merged.containsKey(reference) &&
            !processedReferences.contains(reference)) {
          merged[reference]?.updateReferences(analyzer.nameFile);
          processedReferences.add(reference);
        }
      }
    }

    return merged.values.toList();
  }

  Future<void> analyze() async {
    fileAnalyzers.clear();
    for (var file in files) {
      try {
        final filePath = file.path;
        final fileName = file.uri.pathSegments.last;
        final fileImports = await getImportsFromFile(filePath);

        // Cria um novo FileAnalyzer ou atualiza o existente
        final analyzer = fileAnalyzers.putIfAbsent(
          fileName,
          () => FileAnalyzer(nameFile: fileName, path: filePath),
        );

        analyzer.imports.addAll(fileImports);

        updateFileAnalyzers(file, fileImports);
      } catch (e) {
        print('Error analyzing file: ${file.path}');
      }
    }
  }

  void updateFileAnalyzers(FileSystemEntity file, List<String> fileImports) {
    for (var importPath in fileImports) {
      final importFileName = importPath.split('/').last;

      if (importFileName != file.uri.pathSegments.last) {
        final analyzer = fileAnalyzers.putIfAbsent(
          importFileName,
          () => FileAnalyzer(nameFile: importFileName, path: importPath),
        );

        analyzer.references.add(file.uri.pathSegments.last);
      }
    }
  }

  Future<List<String>> getImportsFromFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final List<String> imports = [];

    // Regex to match Dart import statements
    final matches = importRegex.allMatches(content);
    final exportsMatches = exportRegex.allMatches(content);

    final allMatches = [...matches, ...exportsMatches];

    for (var match in allMatches) {
      String? import = match.group(1) ?? (match.group(2) ?? match.group(3));
      if (import != null) {
        imports.add(import);
      }
    }

    return imports;
  }
}
