import 'package:deep_track_gui/features/map_mind/domain/entities/file_map_analyzer.dart';
import 'package:flutter/material.dart';

class FolderWidget extends StatefulWidget {
  final FileMapMindAnalyzer fileTarget;
  final void Function(bool value) onTapExpand;
  final bool isExpanded;
  final void Function(Pattern patternReferences)? onTapReferences;
  final bool showReferencesButton;
  const FolderWidget({
    Key? key,
    required this.fileTarget,
    required this.onTapExpand,
    required this.isExpanded,
    required this.onTapReferences,
    this.showReferencesButton = true,
  }) : super(key: key);

  @override
  State<FolderWidget> createState() => _FolderWidgetState();
}

class _FolderWidgetState extends State<FolderWidget> {
  late bool isExpanded = widget.isExpanded;

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      widget.onTapExpand(isExpanded);
    });
  }

  Pattern byReferences() {
    return RegExp(widget.fileTarget.references.join("|"));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpand,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.greenAccent, Colors.green],
          ),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.fileTarget.nameFile,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon:
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: toggleExpand,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: !widget.fileTarget.isExternalFile,
              replacement: const Text(
                "Not found more information (External file)",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Imports: ${widget.fileTarget.imports.length}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        "References: ${widget.fileTarget.references.length}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      // botao para navegar para a tela de Mapa mindo com o titulo
                      // referente ao arquivo selecionado
                      // e o pattern para buscar os arquivos
                      Visibility(
                        visible: widget.showReferencesButton,
                        child: IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: () {
                            widget.onTapReferences?.call(byReferences());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
