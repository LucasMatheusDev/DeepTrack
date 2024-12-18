import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:deep_track_cli/deep_track_cli.dart';

const String version = '0.0.1';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand('files')
    ..addCommand('layers')
    ..addCommand('files-and-layers')
    ..addOption('import-regex', abbr: 'i', help: 'Import pattern')
    ..addOption('export-regex', abbr: 'e', help: 'Export pattern')
    ..addOption('file-regex', abbr: 'f', help: 'File pattern')
    ..addOption('layer-regex', abbr: 'l', help: 'Layer pattern')
    ..addOption('path', abbr: 'p', help: 'Path to the project directory');

  final parsedArgs = parser.parse(args);

  if (parsedArgs.command == null) {
    print('Usage: deeptrack-cli <command> --path <directory_path>\n');
    print(parser.usage);
    exit(1);
  }

  final command = parsedArgs.command!.name;
  final directoryPath = parsedArgs['path'] as String?;
  final importPattern = parsedArgs['import-regex'] != null
      ? RegExp(parsedArgs['import-regex'] as String)
      : null;
  final exportPattern = parsedArgs['export-regex'] != null
      ? RegExp(parsedArgs['export-regex'] as String)
      : null;
  final filePattern = parsedArgs['file-regex'] != null
      ? RegExp(parsedArgs['file-regex'] as String)
      : null;
  final layerPattern = parsedArgs['layer-regex'] != null
      ? RegExp(parsedArgs['layer-regex'] as String)
      : null;

  if (directoryPath == null) {
    print('Error: --path is required.');
    exit(1);
  }

  final directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    print('Error: Directory not found at $directoryPath.');
    exit(1);
  }

  if (command == 'analyzer') {
    final files = await analyzerFiles(
      directory,
      importPattern: importPattern,
      exportPattern: exportPattern,
      filePattern: filePattern,
    );
    print(jsonEncode(files.map((f) => f.toJson()).toList()));
  } else if (command == 'layers') {
    final fileAnalyzers = await analyzerFiles(directory);
    final layers = getLayers(
      fileAnalyzers,
      validatePattern: layerPattern,
    );
    print(jsonEncode(layers));
  } else if (command == 'files-and-layers') {
    final fileAnalyzers = await analyzerFiles(
      directory,
      importPattern: importPattern,
      exportPattern: exportPattern,
      filePattern: filePattern,
    );
    final layers = getLayers(
      fileAnalyzers,
      validatePattern: layerPattern,
    );
    print(jsonEncode({
      'files': fileAnalyzers.map((e) => e.toJson()).toList(),
      'layers': layers,
    }));
  } else {
    print('Unknown command: $command');
    print(parser.usage);
    exit(1);
  }
}

Future<List<FileSystemEntity>> getDartFilesFromDirectory(Directory directory,
    {RegExp? pattern}) async {
  final dartFiles = <FileSystemEntity>[];
  pattern ??= RegExp(r'\.dart$');
  await for (var entity in directory.list(recursive: true)) {
    if (entity is File && pattern.hasMatch(entity.path)) {
      dartFiles.add(entity);
    }
  }

  return dartFiles;
}

Future<List<FileAnalyzer>> analyzerFiles(
  Directory directory, {
  RegExp? importPattern,
  RegExp? exportPattern,
  RegExp? filePattern,
}) async {
  final filesSystem =
      await getDartFilesFromDirectory(directory, pattern: filePattern);

  final fileAnalyzer = await AnalyzerImportsCommand().analyze(
    filesSystem,
    importPattern: importPattern,
    exportPattern: exportPattern,
  );

  return fileAnalyzer.fileAnalyzers;
}

List<Layer> getLayers(
  List<FileAnalyzer> fileAnalyzers, {
  RegExp? validatePattern,
}) {
  final analyzerLayersCommand = AnalyzerLayersCommand(
    fileAnalyzers: fileAnalyzers,
    validatePattern: validatePattern,
  );
  return analyzerLayersCommand.analyzeLayers();
}
