import 'package:deep_track_cli/models/file_analyzer.dart';
import 'package:deep_track_cli/models/layer.dart';

class AnalyzerLayersCommand {
  final List<FileAnalyzer> fileAnalyzers;
  final RegExp? validatePattern;

  AnalyzerLayersCommand({
    required this.fileAnalyzers,
    this.validatePattern,
  });

  List<Layer> analyzeLayers() {
    final Map<String, List<FileAnalyzer>> layerMap = {};
    final resultLayers = <String, Layer>{};

    for (var fileAnalyzer in fileAnalyzers) {
      final layer = inferLayer(fileAnalyzer.path);
      if (layer != null) {
        layerMap.putIfAbsent(layer, () => []).add(fileAnalyzer);
      }
    }

    for (var layer in layerMap.keys) {
      final files = layerMap[layer]!;
      final importsLayers = List<Layer>.from([], growable: true);
      final references = List<Layer>.from([], growable: true);
      final subLayers = List<Layer>.from([], growable: true);
      final otherLayers = layerMap.keys.toList();
      otherLayers.remove(layer);
      for (var otherLayer in otherLayers) {
        final otherFiles = layerMap[otherLayer]!;
        final referencesLayer = files
            .where((file) => otherFiles.any((otherFile) =>
                file.references.contains(otherFile.nameFile) ||
                otherFile.imports.toString().contains(layer)))
            .toList();
        if (referencesLayer.isNotEmpty) {
          references.add(Layer(
            name: otherLayer,
            files: [],
            imports: [],
            references: [],
            subLayers: [],
          ));
        }
        final importLayers = files
            .where((file) => otherFiles.any((otherFile) =>
                otherFile.references.contains(file.nameFile) ||
                file.imports.toString().contains(otherLayer)))
            .toList();

        if (importLayers.isNotEmpty) {
          importsLayers.add(Layer(
            name: otherLayer,
            files: [],
            imports: [],
            references: [],
            subLayers: [],
          ));
        }

        Layer? result = resultLayers[layer];
        if (result != null) {
          final newImports =
              <Layer>{...result.imports, ...importsLayers}.toList();
          final newReferences =
              <Layer>{...result.references, ...references}.toList();
          final newSubLayers =
              <Layer>{...result.subLayers, ...subLayers}.toList();
          result = Layer(
            name: result.name,
            files: result.files,
            imports: newImports,
            references: newReferences,
            subLayers: newSubLayers,
          );
        } else {
          result = Layer(
            name: layer,
            files: files,
            imports: importsLayers,
            references: references,
            subLayers: subLayers,
          );
        }
        resultLayers[layer] = result;
      }
      final resultLayer = resultLayers[layer];
      final subLayersList = files.map((file) {
        final splitPaths = file.path.split(RegExp(r'[\\/]+'));
        splitPaths.removeWhere((element) => inferLayer(element) == null);

        if (splitPaths.length < 2) {
          return null;
        }

        return inferLayer(splitPaths.last);
      }).toList();
      // validando pluralidade de camadas
      subLayersList.removeWhere((element) => element == null);
      subLayersList.removeWhere((element) {
        if (layer.endsWith('s') &&
            subLayersList.contains(layer.substring(0, layer.length - 1))) {
          return true;
        } else {
          return false;
        }
      });

      final resultSubLayer = subLayersList.toSet().toList();

      if (resultSubLayer.isNotEmpty) {
        for (var element in resultSubLayer) {
          subLayers.add(Layer(
            name: element!,
            files: [],
            imports: [],
            references: [],
            subLayers: [],
          ));
        }
        resultLayers[layer] = Layer(
          name: resultLayer!.name,
          files: resultLayer.files,
          imports: resultLayer.imports,
          references: resultLayer.references,
          subLayers: subLayers,
        );
      }
    }

    // sort layers
    resultLayers.forEach((key, value) {
      value.subLayers.sort((a, b) => a.name.compareTo(b.name));
      value.references.sort((a, b) => a.name.compareTo(b.name));
    });

    return resultLayers.values.toList();
  }

  /// Infere a camada com base no caminho do arquivo
  String? inferLayer(String path) {
    final parts = path.split(RegExp(r'[\\/]+'));

    for (var part in parts) {
      final previousPartIndex = parts.indexOf(part) - 1;
      final previousPart =
          previousPartIndex >= 0 ? parts[previousPartIndex] : null;

      final validLayerRules = [
        !part.contains('feature') && !part.contains('modules'),
        !part.contains('lib'),
        !part.contains(':') && !part.contains('.'),
        !(previousPart?.contains('feature') ?? false),
        !(previousPart?.contains('module') ?? false),
        !(previousPart?.contains(':') ?? false),
        (parts.contains('lib')
            ? parts.indexOf(part) > parts.indexOf('lib')
            : true),
      ];

      if (validatePattern != null) {
        return validatePattern!.hasMatch(part) ? part : null;
      }

      if (part.contains('.') || part.contains(':')) {
        return null;
      }
      if (validLayerRules.every((element) => element)) {
        return part;
      }
    }
    return null; // Retorna null se nenhuma camada for identificável
  }
}
