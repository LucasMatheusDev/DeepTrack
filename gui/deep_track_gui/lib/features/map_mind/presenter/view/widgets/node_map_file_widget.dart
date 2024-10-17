import 'dart:developer';

import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/pages/map_mind_page.dart';
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
  List<FileMapMindAnalyzer> getChildren() {
    List<FileMapMindAnalyzer> children = [];
    log("Total imports: ${widget.fileTarget.imports.length}");

    for (var import in widget.fileTarget.imports) {
      final file = widget.allFiles.where((element) => element.path == import);
      if (file.isNotEmpty) {
        children.add(file.first);
      } else {
        final name = import.split("/").last;
        FileMapMindAnalyzer file =
            FileMapMindAnalyzer.external(nameFile: name, path: import);

        children.add(file);
      }
    }
    return children;
  }

  final _isExpanded = ValueNotifier(false);

  @override
  void initState() {
    _isExpanded.value = widget.isOpen;
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

  bool hasActiveReferences() {
    return widget.allFiles.where((element) {
      return byReferences().hasMatch(element.path);
    }).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final children = getChildren();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FolderWidget(
              isExpanded: _isExpanded.value,
              fileTarget: widget.fileTarget,
              showReferencesButton: hasActiveReferences(),
              onTapReferences: (_) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapaMindPage(
                    title: "References by ${widget.fileTarget.nameFile}",
                    pattern: byReferences(),
                    filterFiles: widget.allFiles.where((element) {
                      return byReferences().hasMatch(element.path);
                    }).toList(),
                    allFiles: widget.allFiles,
                  ),
                ));
              },
              onTapExpand: (value) {
                _isExpanded.value = value;
              }),
          ValueListenableBuilder(
            valueListenable: _isExpanded,
            builder: (context, isExpanded, child) => isExpanded
                ? MindMap(
                    dotColor: Colors.red,
                    dotPath: pathNode(
                      const Size(50, 50),
                    ),
                    children: children
                        .map((file) => NodeMapFileWidget(
                              fileTarget: file,
                              allFiles: widget.allFiles,
                            ))
                        .toList(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
