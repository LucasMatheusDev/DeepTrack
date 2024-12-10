import 'package:deep_track_cli/commands/analyzer_imports_command.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/circle_with_text.dart';
import 'package:flutter/material.dart';

class CircleLayerWidget extends StatefulWidget {
  final List<Layer> layers;
  final Layer? layerSelected;
  final bool enableHover;
  final void Function(Layer? layer)? onHoverLayer;
  const CircleLayerWidget({
    super.key,
    required this.layers,
    this.layerSelected,
    this.enableHover = true,
    this.onHoverLayer,
  });

  @override
  State<CircleLayerWidget> createState() => _CircleLayerWidgetState();
}

class _CircleLayerWidgetState extends State<CircleLayerWidget> {
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
  Widget build(BuildContext context) {
    final sortLayers = sortLayersByFlowImport();
    const size = 550;
    final layersLength = sortLayers.length;
    final double layerThickness = size / (layersLength * 2);

    return Stack(
      alignment: Alignment.center,
      children: [
        ...sortLayers.map((e) {
          final index = sortLayers.indexOf(e);
          final double radius = size / 2 - (index * layerThickness);

          return Opacity(
            opacity: widget.layerSelected == e ? 1 : 0.5,
            child: CircleWithText(
              totalLayers: layersLength,
              layer: e,
              index: index,
              onHoverLayer: widget.onHoverLayer,
              radius: radius,
              enableHover: widget.enableHover,
              focusLayer: widget.layerSelected,
            ),
          );
        }).toList(),
      ],
    );
  }
}
