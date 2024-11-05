import 'dart:developer';

import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/domain/entities/map_mind_entity.dart';
import 'package:deep_track_gui/features/map_mind/presenter/controllers/map_mind_controller.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/pages/delete_suggest_files_page.dart';
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

class _MapaMindPageState extends State<MapaMindPage>
    with TickerProviderStateMixin {
  final MapMindProjectController controller = MapMindProjectController();

  final scrollController = ScrollController();

  final selectedIndex = ValueNotifier<int>(0);

  late final searchControllerEditing = TextEditingController(
      text: widget.pattern is RegExp
          ? (widget.pattern as RegExp).pattern
          : widget.pattern?.toString());
  final TransformationController transformationController =
      TransformationController();

  final pageViewController = PageController();
  late final TabController tabController =
      TabController(length: 2, vsync: this);

  final indexPage = ValueNotifier<int>(0);

  @override
  void initState() {
    if (widget.allFiles?.isNotEmpty == true) {
      controller.initialValue(widget.allFiles!);
    }
    super.initState();
  }

  List<FileMapMindAnalyzer> filesFiltered(FilesAnalyzerInfo analyzerInfo) {
    final text = RegExp(searchControllerEditing.text.trim());
    log('regex: $text');

    final filerFiles = (widget.filterFiles ?? analyzerInfo.fileAnalyzer)
        .where((element) => text.hasMatch(element.path))
        .toList();
    return filerFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          onTap: (index) {
            pageViewController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            indexPage.value = index;
          },
          controller: tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.folder),
              text: 'Files',
            ),
            Tab(
              icon: Icon(Icons.delete_forever),
              text: 'Analyzer Delete files',
            ),
          ],
        ),
        title: Text(widget.title),
        toolbarHeight: 80,
        actions: [
          ValueListenableBuilder(
            valueListenable: controller.state,
            builder: (context, state, child) {
              if (state.isSuccess) {
                final files = state.asSuccess.byFilter(
                    filter: (value) => RegExp(searchControllerEditing.text)
                        .hasMatch(value.path));

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
              final text = RegExp(searchControllerEditing.text.trim());
              log('regex: $text');

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
                          onDestinationSelected: (index) {},
                        );
                      }),
                  const SizedBox(width: 10),
                  ValueListenableBuilder(
                    valueListenable: indexPage,
                    builder: (context, index, child) {
                      return Expanded(
                        child: PageView(
                          controller: pageViewController,
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
                                    final filerFiles =
                                        filesFiltered(analyzerInfo);
                                    return MindMap(
                                        children: filerFiles
                                            .map((e) => NodeMapFileWidget(
                                                fileTarget: e,
                                                allFiles: widget.allFiles ??
                                                    filerFiles))
                                            .toList());
                                  },
                                ),
                              ),
                            ),
                            DeleteSuggestFilesPage(
                              filterFiles: filesFiltered(analyzerInfo),
                            ),
                          ],
                        ),
                      );
                    },
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
