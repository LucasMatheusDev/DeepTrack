extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String limit(int limit) {
    return length <= limit ? this : "${substring(0, limit)}...";
  }
}
