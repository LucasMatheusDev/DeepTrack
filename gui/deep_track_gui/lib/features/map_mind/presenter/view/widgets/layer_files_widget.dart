import 'package:deep_track_cli/models/file_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/files_list_widget.dart';
import 'package:flutter/material.dart';

class LayerFilesWidget extends StatefulWidget {
  final List<FileAnalyzer> files;

  const LayerFilesWidget({Key? key, required this.files}) : super(key: key);

  @override
  State<LayerFilesWidget> createState() => _LayerFilesWidgetState();
}

class _LayerFilesWidgetState extends State<LayerFilesWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurando o AnimationController e a animação de fade
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Inicia a animação
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Files:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FilesListWidget(
                  files: widget.files,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
