import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/button_take_screenshot_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/node_map_file_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/not_found_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/visible_only_if_on_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

class MapMindPage extends StatefulWidget {
  final FilesAnalyzerInfo analyzerInfo;
  final List<FileMapMindAnalyzer> filterFiles;
  const MapMindPage({
    super.key,
    required this.analyzerInfo,
    required this.filterFiles,
  });

  @override
  State<MapMindPage> createState() => _MapMindPageState();
}

class _MapMindPageState extends State<MapMindPage> {
  TransformationController transformationController = TransformationController(
    Matrix4.identity(),
  );

  Future<void> resetPositionAndZoom() async {
    transformationController.toScene(const Offset(0, 0));
    transformationController.value = Matrix4.identity();
  }

  @override
  void didUpdateWidget(MapMindPage oldWidget) {
    if (oldWidget.filterFiles != widget.filterFiles) {
      resetPositionAndZoom();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final repaintBoundaryKey = GlobalKey();

    return Visibility(
      visible: widget.filterFiles.isNotEmpty,
      replacement: const NotFound(message: 'No files to show'),
      child: SafeArea(
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: transformationController,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 2,
              constrained: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height,
                  minWidth: MediaQuery.sizeOf(context).width,
                ),
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
                            children: widget.filterFiles
                                .map((file) => VisibleOnlyIfOnScreenWidget(
                                      key: ValueKey(file.path),
                                      isVisible:
                                          widget.filterFiles.indexOf(file) < 30,
                                      placeholderSize: const Size(250, 250),
                                      child: NodeMapFileWidget(
                                        fileTarget: file,
                                        allFiles:
                                            widget.analyzerInfo.fileAnalyzer,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: () {
                        transformationController.value *=
                            Matrix4.diagonal3Values(
                          0.9,
                          0.9,
                          1,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () {
                        transformationController.value *=
                            Matrix4.diagonal3Values(
                          1.1,
                          1.1,
                          1,
                        );
                      },
                    ),
                    // up
                    IconButton(
                      icon: const Icon(Icons.arrow_upward),
                      onPressed: () {
                        // para o topo
                        resetPositionAndZoom();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
