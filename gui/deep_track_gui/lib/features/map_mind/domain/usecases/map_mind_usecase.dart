import 'dart:io';

import 'package:answer/answer.dart';
import 'package:deep_track_cli/commands/analyzer_imports_command.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/search_files_filter.dart';

class MapMindUseCase {
  AnalyzerImportsCommand analyzerImportsCommand =
      AnalyzerImportsCommand(saveOutput: false);
  Future<AnswerDefault<FilesAnalyzerInfo>> getFilesAnalysis(
    SearchFilesFilter filter,
  ) async {
    final filesAnalyzed = await getFilesMap(filter);

    return Answer.success(filesAnalyzed);
  }

  Future<FilesAnalyzerInfo> getFilesMap(
    SearchFilesFilter filter,
  ) async {
    final filesSystem = await getSystemFiles(filter);
    final filesAnalyzed = await analyzerImportsCommand.analyze(
      filesSystem,
      importPattern: filter.imporPattern,
    );

    return FilesAnalyzerInfo(
      filesAnalyzed.fileAnalyzers
          .map((e) => FileMapMindAnalyzer(
                nameFile: e.nameFile,
                imports: e.imports,
                path: e.path,
                references: e.references,
              ))
          .toList(),
      layers: filesAnalyzed.analyzeLayers().values.toList(),
    );
  }

  Future<List<FileSystemEntity>> getSystemFiles(
      SearchFilesFilter filterPattern) async {
    final dartFiles = <FileSystemEntity>[];
    final directory = Directory(filterPattern.basePath);

    await for (var entity in directory.list(recursive: true)) {
      if (entity is File &&
          filterPattern.patternsFiles
              .any((pattern) => pattern.allMatches(entity.path).isNotEmpty)) {
        dartFiles.add(entity);
      }
    }

    return dartFiles;
  }
}
