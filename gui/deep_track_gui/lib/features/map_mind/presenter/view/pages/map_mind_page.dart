import 'dart:developer';

import 'package:deep_track_cli/models/file_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/search_files_filter.dart';
import 'package:deep_track_gui/features/map_mind/presenter/controllers/map_mind_controller.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/node_map_file_widget.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/searching_filter_form.dart';
import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

class MapaMindPage extends StatefulWidget {
  final String title;
  final Pattern? pattern;
  final List<FileMapMindAnalyzer>? filterFiles;
  final List<FileMapMindAnalyzer>? allFiles;
  const MapaMindPage({
    super.key,
    this.title = 'Mind Map Project',
    this.pattern,
    this.filterFiles,
    this.allFiles,
  });

  @override
  State<MapaMindPage> createState() => _MapaMindPageState();
}

class _MapaMindPageState extends State<MapaMindPage> {
  final MapMindProjectController controller = MapMindProjectController();

  final scrollController = ScrollController();

  final selectedIndex = ValueNotifier<int>(0);

  late final searchControllerEditing = TextEditingController(
      text: widget.pattern is RegExp
          ? (widget.pattern as RegExp).pattern
          : widget.pattern?.toString());
  final TransformationController transformationController =
      TransformationController();

  @override
  void initState() {
    if (widget.allFiles?.isNotEmpty == true) {
      // filesAnalyzed.value = [...?widget.allFiles];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        toolbarHeight: 80,
        actions: [
          ValueListenableBuilder(
            valueListenable: controller.state,
            builder: (context, state, child) {
              if (state.isSuccess) {
                final files = state.asSuccess.fileAnalyzer;

                return Visibility(
                  visible: files.isNotEmpty,
                  child: SearchBar(
                    controller: searchControllerEditing,
                    leading: const Icon(Icons.search),
                    constraints:
                        const BoxConstraints(maxWidth: 350, maxHeight: 80),
                    onChanged: (value) {
                      // final files = controller.searchFiles(value);
                      // filesAnalyzed.value = files;
                    },
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          const SizedBox(
            width: 40,
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: controller.state,
          builder: (context, state, child) {
            if (state.isSuccess) {
              final analyzerInfo = state.asSuccess;
              return Row(
                children: [
                  ValueListenableBuilder(
                      valueListenable: selectedIndex,
                      builder: (context, _, child) {
                        return NavigationRail(
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.folder),
                              label: Text('Files'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.map),
                              label: Text('Mind Map'),
                            ),
                          ],
                          selectedIndex: 1,
                          onDestinationSelected: (index) {
                            controller.getFilesAnalysis(SearchFilesFilter(
                                basePath:
                                    r"C:\Users\lucas\StudioProjects\Projetos_Flutter\battle_flow\lib",
                                patternsFiles: [
                                  // todos aquivos que contem .dart
                                  "",
                                ]));

                            selectedIndex.value = index;
                          },
                        );
                      }),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        SafeArea(
                          child: InteractiveViewer(
                              boundaryMargin: const EdgeInsets.all(100),
                              minScale: 0.1,
                              maxScale: 2.5,
                              constrained: false,
                              child: ValueListenableBuilder(
                                valueListenable: searchControllerEditing,
                                builder: (context, search, _) {
                                  final text = RegExp(
                                      searchControllerEditing.text.trim());
                                  log('regex: $text');

                                  final filerFiles = (widget.filterFiles ??
                                          analyzerInfo.fileAnalyzer)
                                      .where((element) =>
                                          text.hasMatch(element.path))
                                      .toList();
                                  return MindMap(
                                      children: filerFiles
                                          .map((e) => NodeMapFileWidget(
                                              fileTarget: e,
                                              allFiles: widget.allFiles ??
                                                  filerFiles))
                                          .toList());
                                },
                              )),
                        ),
                        ValueListenableBuilder(
                            valueListenable: controller.state,
                            builder: (context, isLoading, child) {
                              if (state.isLoading) {
                                return Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return const SizedBox();
                            }),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.zoom_in),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.zoom_out),
                                onPressed: () {
                                  transformationController.toScene(Offset.zero);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state.isError) {
              return Center(
                child: Text(state.asError.message),
              );
            } else {
              return SearchFilesFilterForm(
                onSubmit: (filter) {
                  controller.getFilesAnalysis(filter);
                },
              );
            }
          }),
    );
  }
}

class NotFoundFileAnalyzer extends FileAnalyzer {
  NotFoundFileAnalyzer({
    required String nameFile,
    required String path,
    List<String>? references,
  }) : super(nameFile: nameFile, path: path, references: references);
}
