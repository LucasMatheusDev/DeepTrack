import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/widgets/files_list_widget.dart';
import 'package:flutter/material.dart';

class DeleteSuggestFilesPage extends StatefulWidget {
  final List<FileMapMindAnalyzer> filterFiles;

  const DeleteSuggestFilesPage({super.key, required this.filterFiles});

  @override
  State<DeleteSuggestFilesPage> createState() => _DeleteSuggestFilesPageState();
}

class _DeleteSuggestFilesPageState extends State<DeleteSuggestFilesPage> {
  List<FileMapMindAnalyzer> get filesFilteredWithNoReferences {
    return widget.filterFiles
        .where((element) => element.references.isEmpty)
        .toList();
  }

  ValueNotifier<List<FileMapMindAnalyzer>> selectedFiles = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: filesFilteredWithNoReferences.isNotEmpty,
      replacement: const Center(
        child: Text('No files to delete'),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: FilesListWidget(
          files: filesFilteredWithNoReferences,
        ),
      ),
    );
  }
}
