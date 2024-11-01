import 'package:deep_track_gui/features/map_mind/domain/entities/search_files_filter.dart';
import 'package:flutter/material.dart';

class SearchFilesFilterForm extends StatefulWidget {
  final void Function(SearchFilesFilter) onSubmit;
  const SearchFilesFilterForm({super.key, required this.onSubmit});

  @override
  State<SearchFilesFilterForm> createState() => _SearchFilesFilterFormState();
}

class _SearchFilesFilterFormState extends State<SearchFilesFilterForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos do formulário
  final TextEditingController _basePathController = TextEditingController();
  final TextEditingController _patternsFilesController =
      TextEditingController();
  final TextEditingController _importPatternController =
      TextEditingController();

  final infoAboutBasePath =
      'The base path is the directory where the search will start. '
      'In Flutter projects, it is usually the "lib" directory';

  final infoAboutPatternsFiles =
      'The pattern files are filters that will be used to search file names. '
      'You can use regular expressions to filter the files. '
      'Examples: *.dart, .jar, /domain/**, /data/**.';

  final infoAboutImportPattern =
      'The import pattern is a regular expression that will be used to '
      'identify file imports. In Flutter projects, a regex like import '
      'package:.* can be used to filter imports.';

      
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width:
              500, // Definindo uma largura para parecer um formulário quadrado
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Search Files Filter',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Campo para basePath
                TextFormField(
                  controller: _basePathController,
                  decoration: InputDecoration(
                    labelText: 'Base Path',
                    hintText: 'Enter the base path for analysis',
                    border: const OutlineInputBorder(),
                    helperText: 'The path where the search will start',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        showFilterInfoDialog(
                          context,
                          infoAboutBasePath,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a base path';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo para patternsFiles
                TextFormField(
                  controller: _patternsFilesController,
                  decoration: InputDecoration(
                    labelText: 'Patterns Files (comma-separated)',
                    hintText: 'Example: .dart,.js,.css',
                    border: const OutlineInputBorder(),
                    helperText: 'Filters to search for files',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        showFilterInfoDialog(
                          context,
                          infoAboutPatternsFiles,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para imporPattern (opcional)
                TextFormField(
                  controller: _importPatternController,
                  decoration: InputDecoration(
                    labelText: 'Import Pattern (optional)',
                    border: const OutlineInputBorder(),
                    helperText: 'Regular expression to identify file imports',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        showFilterInfoDialog(
                          context,
                          infoAboutImportPattern,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botão para enviar o formulário
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Valida o formulário e envia os dados
                      final basePath = _basePathController.text;
                      final patternsFiles =
                          _patternsFilesController.text.split(',');
                      final importPattern =
                          _importPatternController.text.isNotEmpty
                              ? RegExp(_importPatternController.text)
                              : null;

                      final searchFilesFilter = SearchFilesFilter(
                        basePath: basePath,
                        patternsFiles:
                            patternsFiles.map((e) => RegExp(e)).toList(),
                        imporPattern: importPattern,
                      );

                      widget.onSubmit(searchFilesFilter);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 50), // Largura completa
                  ),
                  child: const Text('Analisar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// simple dialog for show info about filters
Future<void> showFilterInfoDialog(BuildContext context, String info) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Filter Info'),
        content: Text(info),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
