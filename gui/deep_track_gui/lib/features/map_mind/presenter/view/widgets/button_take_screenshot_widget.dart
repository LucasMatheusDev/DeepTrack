import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ButtonTakeScreenShot extends StatefulWidget {
  final bool isVisible;
  final GlobalKey repaintBoundaryKey;
  const ButtonTakeScreenShot({
    required this.isVisible,
    required this.repaintBoundaryKey,
  }) : super(
          key: null,
        );

  @override
  State<ButtonTakeScreenShot> createState() => _ButtonTakeScreenShotState();
}

class _ButtonTakeScreenShotState extends State<ButtonTakeScreenShot> {
  static final ValueNotifier<bool> _isHidden = ValueNotifier(false);

  Future<void> hideWhileFunction(Future Function() function) async {
    _isHidden.value = true;
    await function();
    _isHidden.value = false;
  }

  Future<void> takeScreenshot() async {
    final boundary = widget.repaintBoundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      log("Erro ao encontrar o boundary.");
      return;
    }

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 20));
      return takeScreenshot();
    }

    var image = await boundary.toImage(pixelRatio: 3.0);
    var byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Image.memory(byteData.buffer.asUint8List()),
            actions: [
              // download button
              TextButton(
                child: const Text("Download"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await downloadFileFromBytes(
                    byteData.buffer.asUint8List(),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      log("Erro ao converter a imagem para ByteData.");
    }
  }

  Future<void> downloadFileFromBytes(List<int> bytes) async {
    try {
      // Obtém o diretório onde o arquivo será salvo
      final date = DateTime.now().toIso8601String();
      final dateName = date.replaceAll(":", "_").replaceAll(".", "_");
      final fileName = 'screenshot_dt_$dateName.png';

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Cria um arquivo e escreve os bytes nele
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo salvo em: $filePath'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar o arquivo: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isHidden,
      builder: (context, isHidden, child) => Visibility(
        visible: widget.isVisible && !isHidden,
        child: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          color: Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: Colors.transparent,
          onPressed: () {
            hideWhileFunction(() async {
              await takeScreenshot();
            });
            // takeScreenshot();
          },
          icon: Icon(
            Icons.camera_alt_outlined,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
