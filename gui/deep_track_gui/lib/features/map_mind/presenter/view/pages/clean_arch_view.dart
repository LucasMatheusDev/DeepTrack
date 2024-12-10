import 'dart:math';

import 'package:deep_track_cli/commands/analyzer_imports_command.dart';
import 'package:deep_track_gui/core/utils/string_extension.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/map_mind_base_view.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/circle_layer_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/curved_text.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/layer_files_widget.dart';
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
  List<Layer> sortLayersByFlowImport() {
    final visited = <Layer>{};
    final sortedLayers = <Layer>[];

    void visit(Layer layer) {
      if (visited.contains(layer)) return;
      visited.add(layer);

      for (final reference in layer.references) {
        final dependentLayer = widget.layers
            .firstWhere((l) => l.name == reference.name, orElse: () => layer);
        visit(dependentLayer);
      }

      sortedLayers.add(layer);
    }

    for (final layer in widget.layers) {
      visit(layer);
    }

    return sortedLayers;
  }

  @override
  void initState() {
    sortLayersByFlowImport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Visibility(
        visible: widget.layers.isNotEmpty,
        replacement: const NotFound(message: 'No layers to show'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final double size = constraints.maxWidth * 0.45;

                return SingleChildScrollView(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: rotateNotifier,
                            builder: (context, rotate, _) => InteractiveViewer(
                              child: Transform.rotate(
                                angle: rotate,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 600,
                                    maxWidth: 600,
                                  ),
                                  child: Center(
                                    child: ValueListenableBuilder(
                                      valueListenable: selectedLayer,
                                      builder: (context, layerSelected, _) =>
                                          CircleLayerWidget(
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
                          ValueListenableBuilder(
                            valueListenable: rotateNotifier,
                            builder: (context, rotate, _) => LimitedBox(
                              maxHeight: 50,
                              maxWidth: size,
                              child: Slider(
                                value: rotateNotifier.value,
                                onChanged: (value) =>
                                    rotateNotifier.value = value,
                                min: 0,
                                max: 2 * 3.141592653589793,
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
                                            icon: const Icon(Icons.search),
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
                                                          nameFile: e.nameFile,
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
                                                          (sub) => ref.contains(
                                                              sub.name))));

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
                                      Visibility(
                                        visible: layer.references.isNotEmpty,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text('References',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                            ...layer.references
                                                .map((e) => Text(e.name,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ))),
                                            const Divider(),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: layer.imports.isNotEmpty,
                                        child: Column(
                                          children: [
                                            const Text('Imports',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                            ...layer.imports
                                                .map((e) => Text(e.name,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ))),
                                            const Divider(),
                                          ],
                                        ),
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
                return LayerFilesWidget(files: layer.files);
              },
            ),
          ],
        ),
      ),
    );
  }

  final fixedHover = ValueNotifier<Layer?>(null);

  List<Widget> buildLayerCircles({
    required double size,
    required List<Layer> layers,
    void Function(Layer? layer)? onHoverLayer,
    required Offset center,
    Layer? selectedLayer,
  }) {
    final double layerThickness = size / (layers.length * 2);
    List<Widget> circles = [];

    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final double radius = size / 2 - (i * layerThickness);

      circles.add(Opacity(
        opacity: selectedLayer == null || selectedLayer == layer ? 1 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Stack(
            children: [
              MouseRegion(
                onHover: (event) {
                  onHoverLayer?.call(fixedHover.value ?? layer);
                },
                child: GestureDetector(
                  onTap: () {
                    if (fixedHover.value == layer) {
                      fixedHover.value = null;
                    } else {
                      fixedHover.value = layer;
                    }
                  },
                  child: Stack(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: fixedHover,
                        builder: (context, hover, _) {
                          return Visibility(
                            visible: hover == layer,
                            child: Positioned(
                              left: radius - 20,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.gps_fixed,
                                  color: Colors.purple,
                                ),
                                onPressed: () {
                                  fixedHover.value = null;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.accents[i % Colors.accents.length]
                              .withOpacity(0.2),
                          border: Border.all(
                            color:
                                Colors.primaries[i % Colors.primaries.length],
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Text along the circle
              ...buildTextAlongCircle(
                radius: radius,
                texts:
                    ([layer.name] + layer.subLayers.map((e) => e.name).toList())
                        .toSet()
                        .toList(),
                center: Offset(radius, radius),
                color: Colors.primaries[(i % Colors.primaries.length)],
              ).map((e) => Padding(
                    padding: EdgeInsets.only(left: radius, top: radius),
                    child: e,
                  )),
            ],
          ),
        ),
      ));
    }

    return circles;
  }

  List<Widget> buildTextAlongCircle({
    required double radius,
    required List<String> texts,
    required Offset center,
    required Color color,
  }) {
    final double angleStep = 2 * 3.141592653589793 / texts.length;
    List<Widget> textWidgets = [];

    for (int i = 0; i < texts.length; i++) {
      final double angle = i * angleStep - 3.141592653589793 / 2;

      final double x = center.dx + angle + radius * 0.85 * cos(angle);
      final double y = center.dy + angle + radius * 0.85 * sin(angle);

      textWidgets.add(
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(i * angleStep),
          child: CurvedText(
            radius: radius + 5,
            text: texts[i].capitalize(),
            textStyle: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return textWidgets;
  }
}

// class FlowImportLayerWidget extends StatelessWidget {
//   final List<Layer> layers;
//   final Layer? layerSelected;
//   final bool enableHover;
//   const FlowImportLayerWidget({
//     super.key,
//     required this.layers,
//     this.layerSelected,
//     this.enableHover = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: buildLayerCircles(
//         size: 550,
//         layers: layers,
//         center: const Offset(275, 275),
//         selectedLayer: layerSelected,
//         onHoverLayer: (layer) {
//           if (layer != layerSelected && enableHover) {
//             selectedLayer.value = layer;
//           }
//         },
//       ),
//     );
//   }
// }

// class CircleLayer extends StatelessWidget {
//   const CircleLayer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
