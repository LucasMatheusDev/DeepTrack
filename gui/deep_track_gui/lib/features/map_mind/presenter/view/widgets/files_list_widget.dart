import 'package:deep_track_cli/models/file_analyzer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilesListWidget extends StatefulWidget {
  final List<FileAnalyzer> files;
  final Widget Function(FileAnalyzer file)? bottomFile;

  const FilesListWidget({
    Key? key,
    required this.files,
    this.bottomFile,
  }) : super(key: key);

  @override
  State<FilesListWidget> createState() => _FilesListWidgetState();
}

class _FilesListWidgetState extends State<FilesListWidget>
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
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.files.length,
        itemBuilder: (context, index) {
          final file = widget.files[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _fadeAnimation.drive(
                Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: index < widget.files.length - 1 ? 8.0 : 0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: file.nameFile));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            }
                          },
                        ),
                        title: Text(file.nameFile),
                      ),
                    ),
                    if (widget.bottomFile != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: widget.bottomFile!(file),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
