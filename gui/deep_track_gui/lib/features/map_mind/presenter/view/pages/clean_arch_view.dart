import 'package:deep_track_cli/deep_track_cli.dart';
import 'package:deep_track_gui/core/utils/string_extension.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/map_mind_base_view.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/button_take_screenshot_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/circle_layer_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/files_list_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/info_layer_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/not_found_widget.dart';
import 'package:flutter/material.dart';

class CleanArchVisualization extends StatefulWidget {
  final List<Layer> layers;

  const CleanArchVisualization({Key? key, required this.layers})
      : super(key: key);

  @override
  State<CleanArchVisualization> createState() => _CleanArchVisualizationState();
}

class _CleanArchVisualizationState extends State<CleanArchVisualization> {
  final rotateNotifier = ValueNotifier<double>(0);

  final selectedLayer = ValueNotifier<Layer?>(null);

  final enableHover = ValueNotifier<bool>(true);
  final repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Visibility(
        visible: widget.layers.isNotEmpty,
        replacement: const NotFound(message: 'No layers to show'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double size = constraints.hasInfiniteWidth
                      ? 600
                      : constraints.maxWidth * 0.45;
                  final double sizeHeight = constraints.hasInfiniteWidth
                      ? 600
                      : constraints.maxHeight * 0.9;

                  return SingleChildScrollView(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: rotateNotifier,
                              builder: (context, rotate, _) => LimitedBox(
                                maxHeight: 50,
                                maxWidth: size,
                                child: Row(
                                  children: [
                                    Slider(
                                      value: rotateNotifier.value,
                                      onChanged: (value) =>
                                          rotateNotifier.value = value,
                                      min: 0,
                                      max: 2 * 3.141592653589793,
                                    ),
                                    ButtonTakeScreenShot(
                                      isVisible: true,
                                      repaintBoundaryKey: repaintBoundaryKey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: rotateNotifier,
                              builder: (context, rotate, _) =>
                                  InteractiveViewer(
                                minScale: 0.1,
                                maxScale: 4,
                                alignment: Alignment.center,
                                boundaryMargin: const EdgeInsets.all(30),
                                child: Transform.rotate(
                                  angle: rotate,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: sizeHeight,
                                      maxWidth: sizeHeight,
                                    ),
                                    child: Center(
                                      child: ValueListenableBuilder(
                                        valueListenable: selectedLayer,
                                        builder: (context, layerSelected, _) =>
                                            RepaintBoundary(
                                          key: repaintBoundaryKey,
                                          child: CircleLayerWidget(
                                            size: sizeHeight,
                                            layers: widget.layers,
                                            layerSelected: layerSelected,
                                            enableHover: enableHover.value,
                                            onHoverLayer: (layer) {
                                              if (layer != layerSelected &&
                                                  enableHover.value) {
                                                selectedLayer.value = layer;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                          valueListenable: selectedLayer,
                          builder: (context, layer, _) => layer == null
                              ? const SizedBox()
                              : SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                selectedLayer.value = null;
                                              },
                                            ),
                                            Flexible(
                                              child: SizedBox(
                                                width: 280,
                                                child: Text(
                                                  layer.name.capitalize(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon:
                                                  const Icon(Icons.open_in_new),
                                              onPressed: () {
                                                final allFiles = widget.layers
                                                    .map((e) => e.allFiles())
                                                    .expand((file) => file)
                                                    .toList();

                                                final analyzer =
                                                    FilesAnalyzerInfo(
                                                  allFiles
                                                      .map((e) =>
                                                          FileMapMindAnalyzer(
                                                            nameFile:
                                                                e.nameFile,
                                                            path: e.path,
                                                            imports: e.imports,
                                                            references:
                                                                e.references,
                                                          ))
                                                      .toList(),
                                                  layers: [layer],
                                                );
                                                analyzer.updateRule((file) =>
                                                    file.imports.any((ref) =>
                                                        ref.contains(
                                                            layer.name) ||
                                                        layer.subLayers.any(
                                                            (sub) =>
                                                                ref.contains(sub
                                                                    .name))));

                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MapMindBasePage(
                                                      analyzerInfo: analyzer,
                                                      title:
                                                          "Map Mind by ${layer.name.capitalize()}",
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                        InfoLayerWidget(
                                          layer: layer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: selectedLayer,
                builder: (context, layer, _) {
                  if (layer == null) return const SizedBox();
                  return Expanded(
                    child: FilesListWidget(
                      showDeleteButton: false,
                      files: layer.allFiles(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
