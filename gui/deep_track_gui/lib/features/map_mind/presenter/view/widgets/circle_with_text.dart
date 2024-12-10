import 'package:deep_track_cli/commands/analyzer_imports_command.dart';
import 'package:deep_track_gui/core/utils/string_extension.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/text_along_circle.dart';
import 'package:flutter/material.dart';

class CircleWithText extends StatelessWidget {
  final Layer layer;
  final bool enableHover;
  final Layer? focusLayer;
  final void Function(Layer? layer)? onHoverLayer;
  final int index;
  final double radius;
  final int totalLayers;
  const CircleWithText({
    super.key,
    required this.layer,
    this.enableHover = true,
    this.focusLayer,
    this.onHoverLayer,
    required this.index,
    required this.radius,
    required this.totalLayers,
  });

  List<String> get texts =>
      ([layer.name] + layer.subLayers.map((e) => e.name).toList())
          .toSet()
          .toList();
  static final ValueNotifier<Layer?> fixedHover = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: focusLayer == layer ? 1 : 0.5,
          child: MouseRegion(
            onHover: (event) {
              onHoverLayer?.call(fixedHover.value ?? layer);
            },
            child: GestureDetector(
              onTap: () {
                if (fixedHover.value == layer) {
                  fixedHover.value = null;
                } else {
                  fixedHover.value = layer;
                  onHoverLayer?.call(layer);
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
                      color: Colors.accents[index % Colors.accents.length]
                          .withOpacity(0.2),
                      border: Border.all(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...texts.map(
          (e) {
            final double angleStep = 2 * 3.141592653589793 / texts.length;
            final textIndex = texts.indexOf(e);
            return Padding(
              padding: EdgeInsets.only(left: radius, top: radius),
              child: TextAlongCircle(
                angleStep: angleStep,
                radius: radius,
                text: e.capitalize(),
                index: textIndex,
                color: Colors.primaries[(index % Colors.primaries.length)],
              ),
            );
          },
        ).toList(),
      ],
    );
  }
}
