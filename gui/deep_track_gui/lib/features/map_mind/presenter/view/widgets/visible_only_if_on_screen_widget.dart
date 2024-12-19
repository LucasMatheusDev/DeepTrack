import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibleOnlyIfOnScreenWidget extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final Size placeholderSize;

  const VisibleOnlyIfOnScreenWidget({
    Key? key,
    required this.child,
    this.isVisible = true,
    this.placeholderSize = const Size(250, 250),
  }) : super(key: key);

  @override
  State<VisibleOnlyIfOnScreenWidget> createState() =>
      _VisibleOnlyIfOnScreenWidgetState();
}

class _VisibleOnlyIfOnScreenWidgetState
    extends State<VisibleOnlyIfOnScreenWidget> {
  late bool isVisible = widget.isVisible;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? UniqueKey(),
      onVisibilityChanged: (visibilityInfo) {
        if (mounted) {
          setState(() {
            isVisible = visibilityInfo.visibleFraction >= 0;
          });
        }
      },
      child: isVisible
          ? widget.child
          : SizedBox(
              height: widget.placeholderSize.height,
              width: widget.placeholderSize.width,
            ),
    );
  }
}
