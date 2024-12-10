import 'package:deep_track_cli/models/file_analyzer.dart';

class Layer {
  final String name;
  final List<FileAnalyzer> files;
  final List<Layer> subLayers;
  final List<Layer> references;
  final List<Layer> imports;

  Layer({
    required this.name,
    required this.files,
    required this.subLayers,
    required this.references,
    required this.imports,
  }) {
    removePluralLayer(subLayers);
    removePluralLayer(references);
    removePluralLayer(imports);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'files': files.map((e) => e.toJson()).toList(),
      'subLayers': subLayers.map((e) => e.toJson()).toList(),
      'references': references.map((e) => e.toJson()).toList(),
    };
  }

  void removePluralLayer(List<Layer> layers) {
    final copyList = [...layers];
    for (var layer in copyList) {
      if (layer.name.endsWith('s')) {
        final layerWithoutPlural =
            layer.name.substring(0, layer.name.length - 1);
        layers.any((element) => element.name == layerWithoutPlural)
            ? layers.remove(layer)
            : null;
      }
    }
  }

  List<FileAnalyzer> allFiles() {
    final List<FileAnalyzer> files = List<FileAnalyzer>.empty(growable: true);
    files.addAll([...this.files]);
    for (var layer in subLayers) {
      files.addAll([...layer.allFiles()]);
    }
    return files;
  }

  @override
  String toString() {
    return 'Layer(name: $name, files: $files, subLayers: $subLayers, references: $references, imports: $imports)';
  }
}
