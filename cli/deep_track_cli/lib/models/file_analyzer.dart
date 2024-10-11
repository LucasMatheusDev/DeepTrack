class FileAnalyzer {
  List<String> imports;
  List<String> references;
  String nameFile;
  String path;

  FileAnalyzer({
    required this.nameFile,
    required this.path,
    List<String>? imports,
    List<String>? references,
  })  : imports = imports ?? [],
        references = references ?? [];

  // Adiciona uma nova referência à lista de referências
  void updateReferences(String newReference) {
    if (!references.contains(newReference)) {
      references.add(newReference);
    }
  }

  // Converte o objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'file': nameFile,
      'imports': imports,
      'references': references,
    };
  }

  FileAnalyzer.fromJson(Map<String, dynamic> json)
      : nameFile = json['file'],
        path = json['path'],
        imports = List<String>.from(json['imports']),
        references = List<String>.from(json['references']);
}
