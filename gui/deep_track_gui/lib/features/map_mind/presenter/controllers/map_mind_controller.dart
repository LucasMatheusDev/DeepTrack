import 'package:deep_track_gui/core/value_notifier_state.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/search_files_filter.dart';
import 'package:deep_track_gui/features/map_mind/domain/usecases/map_mind_usecase.dart';

class MapMindProjectController {
  final MapMindUseCase useCase = MapMindUseCase();

  final state = ValueNotifierState<FilesAnalyzerInfo>();

  Future<void> getFilesAnalysis(
    SearchFilesFilter filter,
  ) async {
    state.changeToLoadingState();
    final result = await useCase.getFilesAnalysis(filter);
    result.deal(
      onSuccess: state.changeToSuccessState,
      onFail: state.changeToErrorState,
    );
  }
}
