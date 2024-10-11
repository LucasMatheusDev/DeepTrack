import 'dart:convert';
import 'dart:io';

import 'package:deep_track_cli/models/file_analyzer.dart';

class SuggestionAnalyzer {
  final bool suggestionsFilesRemoved;
  final bool suggestionsFilesWithMoreThanFiveImports;

  SuggestionAnalyzer({
    this.suggestionsFilesRemoved = true,
    this.suggestionsFilesWithMoreThanFiveImports = true,
  });

  Future<Map<String, dynamic>> analyze(List<FileAnalyzer> fileAnalyzers) async {
    String? suggestionsFilesRemovedPath;
    String? suggestionsFilesWithMoreThanFiveImportsPath;
    if (suggestionsFilesRemoved) {
      suggestionsFilesWithMoreThanFiveImportsPath =
          await saveSuggestionsFilesRemoved(fileAnalyzers);
    }

    if (suggestionsFilesWithMoreThanFiveImports) {
      suggestionsFilesRemovedPath =
          await saveSuggestionsFilesWithMoreThanFiveImports(fileAnalyzers);
    }

    return {
      if (suggestionsFilesRemoved)
        'suggestionsFilesRemoved': suggestionsFilesRemovedPath,
      if (suggestionsFilesWithMoreThanFiveImports)
        'suggestionsFilesWithMoreThanFiveImports':
            suggestionsFilesWithMoreThanFiveImportsPath,
    };
  }

  Future<String> saveSuggestionsFilesRemoved(
      List<FileAnalyzer> fileAnalyzers) async {
    List<FileAnalyzer> suggestionsFilesRemoved =
        fileAnalyzers.where((element) => element.references.isEmpty).toList();

    // Ordena os arquivos por nome
    suggestionsFilesRemoved.sort(
        (a, b) => a.nameFile.toLowerCase().compareTo(b.nameFile.toLowerCase()));

    print(
        'Total de arquivos sem referência em outros arquivos: ${suggestionsFilesRemoved.length}');

    // Converte os objetos para JSON
    final result = suggestionsFilesRemoved.map((e) => e.toJson()).toList();

    // Salva o JSON em um arquivo
    final outputFile = File('suggestionsFilesRemoved.json');
    await outputFile.writeAsString(jsonEncode(result));
    print('Output saved to: ${outputFile.path}');
    return outputFile.path;
  }

// arquivos com mais de 5 imports
  Future<String> saveSuggestionsFilesWithMoreThanFiveImports(
      List<FileAnalyzer> fileAnalyzers) async {
    List<FileAnalyzer> suggestionsFilesWithMoreThanFiveImports =
        fileAnalyzers.where((element) => element.imports.length > 5).toList();

    // Ordena os arquivos por nome
    suggestionsFilesWithMoreThanFiveImports.sort(
        (a, b) => a.nameFile.toLowerCase().compareTo(b.nameFile.toLowerCase()));

    print(
        'Total de arquivos com mais de 5 imports: ${suggestionsFilesWithMoreThanFiveImports.length}');

    // Converte os objetos para JSON
    final result =
        suggestionsFilesWithMoreThanFiveImports.map((e) => e.toJson()).toList();

    // Salva o JSON em um arquivo
    final outputFile = File('suggestionsFilesWithMoreThanFiveImports.json');
    await outputFile.writeAsString(jsonEncode(result));
    print('Output saved to: ${outputFile.path}');
    return outputFile.path;
  }
}
