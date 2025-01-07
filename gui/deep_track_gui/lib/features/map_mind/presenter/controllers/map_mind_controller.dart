import 'package:deep_track_cli/models/file_analyzer.dart';
import 'package:deep_track_gui/core/page_state.dart';
import 'package:deep_track_gui/core/value_notifier_state.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/search_files_filter.dart';
import 'package:deep_track_gui/features/map_mind/domain/usecases/map_mind_usecase.dart';

class MapMindProjectController {
  final MapMindUseCase useCase = MapMindUseCase();

  final state = ValueNotifierState<FilesAnalyzerInfo>();

  void initialValue(List<FileMapMindAnalyzer> files) {
    if (state.value.isSuccess) {
      final currentFiles = state.value.asSuccess.fileAnalyzer;
      currentFiles.addAll(files);
    } else {
      state.value = SuccessState(data: FilesAnalyzerInfo(files));
    }
  }
 static SearchFilesFilter? lastFilter;
  Future<void> getFilesAnalysis(
    SearchFilesFilter filter,
  ) async {
    lastFilter = filter;
    state.changeToLoadingState();
    final result = await useCase.getFilesAnalysis(filter);
    result.deal(
      onSuccess: state.changeToSuccessState,
      onFail: state.changeToErrorState,
    );
  }

  Future<void> refreshFilesAnalysis() async {
    final filter = lastFilter;
    if (filter != null) {
      await getFilesAnalysis(filter);
    }
  }

  void deleteFile(FileAnalyzer file) {
    if (state.value.isSuccess) {
      state.asSuccess.fileAnalyzer.remove(file);
      state.value = SuccessState(data: state.asSuccess);
    }
  }
}
