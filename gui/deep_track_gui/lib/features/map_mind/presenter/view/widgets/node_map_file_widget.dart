import 'dart:developer';

import 'package:deep_track_gui/core/utils/string_extension.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/map_mind_base_view.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/button_take_screenshot_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/folder_widget.dart';
import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

class NodeMapFileWidget extends StatefulWidget {
  final FileMapMindAnalyzer fileTarget;
  final List<FileMapMindAnalyzer> allFiles;
  final bool isOpen;
  const NodeMapFileWidget({
    super.key,
    required this.fileTarget,
    required this.allFiles,
    this.isOpen = false,
  });

  @override
  State<NodeMapFileWidget> createState() => _NodeMapFileWidgetState();
}

class _NodeMapFileWidgetState extends State<NodeMapFileWidget> {
  final globalKey = GlobalKey();
  final filesMap = ValueNotifier<List<FileMapMindAnalyzer>?>(null);

  void updateFilesMap() {
    List<FileMapMindAnalyzer> files = [];
    log("Total imports: ${widget.fileTarget.imports.length}");

    for (var import in widget.fileTarget.imports) {
      final file = widget.allFiles.where((element) => element.path == import);
      if (file.isNotEmpty) {
        files.add(file.first);
      } else {
        final name = import.split("/").last;
        FileMapMindAnalyzer file =
            FileMapMindAnalyzer.external(nameFile: name, path: import);

        files.add(file);
      }
    }
    filesMap.value = files;
  }

  final _isExpanded = ValueNotifier(false);

  @override
  void initState() {
    _isExpanded.value = widget.isOpen;
    updateFilesMap();
    super.initState();
  }

  Path pathNode(Size size) {
    return Path()
      ..addOval(
        Rect.fromCircle(center: const Offset(0, 0), radius: 6),
      ); // Linha do conector com 50 de comprimento
  }

  RegExp byReferences() {
    return RegExp(widget.fileTarget.references.join("|"));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RepaintBoundary(
        key: globalKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: _isExpanded,
                  builder: (context, isExpanded, _) => ButtonTakeScreenShot(
                    isVisible: isExpanded,
                    repaintBoundaryKey: globalKey,
                  ),
                ),
                FolderWidget(
                    isExpanded: _isExpanded.value,
                    fileTarget: widget.fileTarget,
                    onTapReferences: (_) {
                      final fileAnalyzer = FilesAnalyzerInfo(
                        widget.allFiles,
                      );
                      fileAnalyzer.updateRule(
                          (file) => byReferences().hasMatch(file.path));
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapMindBasePage(
                          title:
                              "References by ${widget.fileTarget.nameFile.capitalize()}",
                          analyzerInfo: fileAnalyzer,
                        ),
                      ));
                    },
                    onTapExpand: (value) {
                      _isExpanded.value = value;
                    }),
              ],
            ),
            ValueListenableBuilder(
              valueListenable: _isExpanded,
              builder: (context, isExpanded, child) => isExpanded
                  ? ValueListenableBuilder(
                      valueListenable: filesMap,
                      builder: (context, files, child) {
                        if (files == null) {
                          return const SizedBox(
                            width: 50,
                            child: CircularProgressIndicator(),
                          );
                        }
                        return MindMap(
                          dotColor: Colors.red,
                          dotPath: pathNode(
                            const Size(50, 50),
                          ),
                          children: files
                              .map((file) => NodeMapFileWidget(
                                    fileTarget: file,
                                    allFiles: widget.allFiles,
                                  ))
                              .toList(),
                        );
                      })
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
