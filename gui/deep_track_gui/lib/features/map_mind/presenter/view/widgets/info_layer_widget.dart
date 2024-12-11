import 'package:deep_track_cli/deep_track_cli.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/not_found_widget.dart';
import 'package:flutter/material.dart';

class InfoLayerWidget extends StatefulWidget {
  final Layer layer;
  const InfoLayerWidget({super.key, required this.layer});

  @override
  State<InfoLayerWidget> createState() => _InfoLayerWidgetState();
}

class _InfoLayerWidgetState extends State<InfoLayerWidget> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 200,
          maxWidth: constraints.maxWidth,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: pageController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('References', style: TextStyle(fontSize: 16)),
                      Visibility(
                        visible: widget.layer.references.isEmpty,
                        child: const NotFound(message: 'No references to show'),
                      ),
                      ...widget.layer.references.map((e) => Text(e.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ))),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Imports', style: TextStyle(fontSize: 16)),
                      Visibility(
                        visible: widget.layer.imports.isEmpty,
                        child: const NotFound(message: 'No imports to show'),
                      ),
                      ...widget.layer.imports.map((e) => Text(e.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ))),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Sub-Layers', style: TextStyle(fontSize: 16)),
                      Visibility(
                        visible: widget.layer.subLayers.isEmpty,
                        child: const NotFound(message: 'No sub-layers to show'),
                      ),
                      ...widget.layer.subLayers.map((e) => Text(e.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ))),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
