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
                  decoration: const InputDecoration(
                    labelText: 'Base Path',
                    hintText: 'Enter the base path for analysis',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Patterns Files (comma-separated)',
                    hintText: 'Example: .dart,.js,.css',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo para imporPattern (opcional)
                TextFormField(
                  controller: _importPatternController,
                  decoration: const InputDecoration(
                    labelText: 'Import Pattern (optional)',
                    border: OutlineInputBorder(),
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
