import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';

class FilesAnalyzerInfo {
  final List<FileMapMindAnalyzer> fileAnalyzer;

  FilesAnalyzerInfo(this.fileAnalyzer);

  bool Function(FileMapMindAnalyzer) _ruleFilter = (file) => true;
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
}
