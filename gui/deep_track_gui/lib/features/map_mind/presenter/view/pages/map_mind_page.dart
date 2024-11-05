import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/button_take_screenshot_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/node_map_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

class MapMindPage extends StatelessWidget {
  final FilesAnalyzerInfo analyzerInfo;
  final List<FileMapMindAnalyzer> filterFiles;
  const MapMindPage({
    super.key,
    required this.analyzerInfo,
    required this.filterFiles,
  });

  @override
  Widget build(BuildContext context) {
    final repaintBoundaryKey = GlobalKey();
    return SafeArea(
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2.5,
        constrained: false,
        child: Row(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ButtonTakeScreenShot(
                  isVisible: true,
                  repaintBoundaryKey: repaintBoundaryKey,
                ),
                RepaintBoundary(
                  key: repaintBoundaryKey,
                  child: MindMap(
                    children: filterFiles
                        .map((file) => NodeMapFileWidget(
                              fileTarget: file,
                              allFiles: analyzerInfo.fileAnalyzer,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
