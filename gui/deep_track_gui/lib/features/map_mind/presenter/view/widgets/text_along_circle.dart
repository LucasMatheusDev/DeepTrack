import 'package:deep_track_gui/core/utils/string_extension.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/curved_text.dart';
import 'package:flutter/material.dart';

class TextAlongCircle extends StatelessWidget {
  final double radius;
  final String text;
  final int index;
  final Color color;
  final double angleStep;
  const TextAlongCircle({
    super.key,
    required this.radius,
    required this.text,
    required this.index,
    required this.color,
    required this.angleStep,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationZ(index * angleStep),
      child: CurvedText(
        radius: radius + 5,
        text: text.capitalize(),
        textStyle: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
