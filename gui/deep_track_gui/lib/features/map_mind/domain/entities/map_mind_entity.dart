import 'package:deep_track_cli/commands/analyzer_imports_command.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';

class FilesAnalyzerInfo {
  final List<FileMapMindAnalyzer> fileAnalyzer;
  final List<Layer> layers;

  FilesAnalyzerInfo(this.fileAnalyzer, {this.layers = const []});

  bool Function(FileMapMindAnalyzer) _ruleFilter = (file) => true;

  bool Function(FileMapMindAnalyzer) get ruleFilter => _ruleFilter;

  bool updateRule(bool Function(FileMapMindAnalyzer) filter) {
    _ruleFilter = filter;
    return true;
  }

  List<FileMapMindAnalyzer> byFilter({
    bool Function(FileMapMindAnalyzer)? filter,
  }) {
    if (filter != null) {
      updateRule(filter);
    }
    return fileAnalyzer.where(_ruleFilter).toList();
  }

  List<Layer> layerByFilter({
    bool Function(Layer)? filter,
  }) {
    if (filter != null) {
      return layers.where(filter).toList();
    } else {
      return layers.where((layer) {
        final files = layer.files;

        return files.any((file) => _ruleFilter(
              FileMapMindAnalyzer(
                nameFile: file.nameFile,
                imports: file.imports,
                path: file.path,
                references: file.references,
              ),
            ));
      }).toList();
    }
  }

  List<FileMapMindAnalyzer> withoutReferences() {
    return byFilter(filter: (file) => file.references.isEmpty);
  }
}
