import 'package:deep_track_gui/core/application_controller.dart';
import 'package:deep_track_gui/features/map_mind/presenter/view/map_mind_base_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Mind Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ValueListenableBuilder(
          valueListenable: ApplicationController().isLoading,
          builder: (context, isLoading, _) {
            return Stack(
              children: [
                const MapMindBasePage(),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          }),
    );
  }
}
