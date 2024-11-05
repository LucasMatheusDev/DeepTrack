import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:flutter/material.dart';

class DeleteSuggestFilesPage extends StatelessWidget {
  final List<FileMapMindAnalyzer> filterFiles;

  const DeleteSuggestFilesPage({super.key, required this.filterFiles});

  List<FileMapMindAnalyzer> get filesFilteredWithNoReferences {
    return filterFiles.where((element) => element.references.isEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filesFilteredWithNoReferences.length,
      itemBuilder: (context, index) {
        final file = filesFilteredWithNoReferences[index];
        return ListTile(
          title: Text(file.path),
          subtitle: Text(file.references.join('\n')),
        );
      },
    );
  }
}
