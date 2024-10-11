import 'dart:io';

import 'package:deep_track_cli/commands/analyzer_imports_command.dart';
import 'package:deep_track_cli/commands/suggestion_analyzer.dart';

const String version = '0.0.1';

void main(List<String> args) async {
  final directory = Directory('lib');
  final files = await getDartFilesFromDirectory(directory);

  print('Saving output...');
  final result = await AnalyzerImportsCommand().analyze(files);

  await SuggestionAnalyzer().analyze(result.fileAnalyzers);

  print('Finished!');
}

Future<List<FileSystemEntity>> getDartFilesFromDirectory(
    Directory directory) async {
  final dartFiles = <FileSystemEntity>[];

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }

  return dartFiles;
}
