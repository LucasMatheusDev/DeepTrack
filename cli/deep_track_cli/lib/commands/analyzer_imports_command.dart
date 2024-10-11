import 'dart:convert';
import 'dart:io';

import 'package:deep_track_cli/models/analyzer_import.dart';
import 'package:deep_track_cli/models/file_analyzer.dart';

class ResultAnalyzer {
  final String? outputPath;
  final List<FileAnalyzer> fileAnalyzers;

  ResultAnalyzer({
    this.outputPath,
    required this.fileAnalyzers,
  });
}

class AnalyzerImportsCommand {
  final bool saveOutput;

  AnalyzerImportsCommand({
    this.saveOutput = true,
  });

  Future<ResultAnalyzer> analyze(List<FileSystemEntity> files) async {
    final analyzerImport = AnalyzerImport(files);
    await analyzerImport.analyze();

    if (saveOutput) {
      final output = await saveAnalyzer(analyzerImport.fileAnalyzersList);
      return ResultAnalyzer(
          outputPath: output, fileAnalyzers: analyzerImport.fileAnalyzersList);
    }

    print('Total files analyzed: ${analyzerImport.fileAnalyzersList.length}');

    return ResultAnalyzer(fileAnalyzers: analyzerImport.fileAnalyzersList);
  }

  Future<String> saveAnalyzer(List<FileAnalyzer> fileAnalyzers) async {
    // Ordena os arquivos por nome
    fileAnalyzers.sort(
        (a, b) => a.nameFile.toLowerCase().compareTo(b.nameFile.toLowerCase()));

    // Converte os objetos para JSON
    final result = fileAnalyzers.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(result);

    // Salva o JSON em um arquivo
    final outputFile = File('output.json');
    await outputFile.writeAsString(jsonString);
    print('Output saved to: ${outputFile.path}');
    return outputFile.path;
  }
}
