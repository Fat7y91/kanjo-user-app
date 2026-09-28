extension StringHelper on String {
  String get removeLast {
    return substring(0, length - 1);
  }
}
