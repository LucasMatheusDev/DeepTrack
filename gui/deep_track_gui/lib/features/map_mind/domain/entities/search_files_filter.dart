class SearchFilesFilter {
  final String basePath;
  final List<Pattern> patternsFiles;
  final Pattern? imporPattern;

  SearchFilesFilter({
    required this.basePath,
    required this.patternsFiles,
    this.imporPattern,
  });
}
