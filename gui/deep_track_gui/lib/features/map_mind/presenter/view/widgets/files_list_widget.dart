import 'dart:io';

import 'package:deep_track_cli/models/file_analyzer.dart';
import 'package:deep_track_gui/core/application_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FilesListWidget extends StatefulWidget {
  final List<FileAnalyzer> files;
  final Widget Function(FileAnalyzer file)? bottomFile;
  final List<FileAnalyzer> selectedFiles;
  final void Function(FileAnalyzer file)? onSelectedFile;
  final void Function(FileAnalyzer file)? onDeletedFile;
  final bool showDeleteButton;

  const FilesListWidget({
    Key? key,
    required this.files,
    this.bottomFile,
    this.selectedFiles = const [],
    this.onSelectedFile,
    this.onDeletedFile,
    this.showDeleteButton = true,
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

  Future<void> deleteFile(FileAnalyzer target,
      {bool showSnackDeleted = false}) async {
    try {
      ApplicationController().showLoading();
      final fileSystem = File(target.path);
      await fileSystem.delete();
      setState(() {
        widget.files.remove(target);
        widget.onDeletedFile?.call(target);
      });

      if (context.mounted && showSnackDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deleted'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting file: $e'),
          ),
        );
      }
    } finally {
      ApplicationController().hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Total files: ${widget.files.length} ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 10),
            const Spacer(),
            Visibility(
              visible: widget.showDeleteButton,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Delete all'),
                    IconButton(
                      onPressed: () {
                        for (final file in widget.files) {
                          deleteFile(file, showSnackDeleted: false);
                          widget.onDeletedFile?.call(file);
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) => ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                final file = widget.files[index];
                final isShowContent = ValueNotifier(false);
                return ValueListenableBuilder(
                  valueListenable: isShowContent,
                  builder: (context, value, child) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: FadeTransition(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      onTap: () {
                                        isShowContent.value =
                                            !isShowContent.value;
                                      },
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.folder),
                                            // abrir no explorador de arquivos
                                            onPressed: () async {
                                              if (await canLaunchUrlString(
                                                  'file:${file.path}')) {
                                                await launchUrlString(
                                                  'file:${file.path}',
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.copy),
                                            onPressed: () async {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: file.nameFile));
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Copied to clipboard'),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Visibility(
                                            visible: widget.showDeleteButton,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () => deleteFile(file),
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        child: Text(file.nameFile),
                                      ),
                                    ),
                                    Visibility(
                                      visible: value,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          file.path,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
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
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
