class OfficialNameMatcher {
  const OfficialNameMatcher._();

  static T? firstWhereOrNull<T>(
    Iterable<T> values,
    bool Function(T value) test,
  ) {
    for (final value in values) {
      if (test(value)) return value;
    }
    return null;
  }

  static bool same(String left, String right) {
    return canonical(left) == canonical(right);
  }

  static String canonical(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('Ã§', 'c')
        .replaceAll('Ã£', 'a')
        .replaceAll('Ã¡', 'a')
        .replaceAll('Ã ', 'a')
        .replaceAll('Ã¢', 'a')
        .replaceAll('Ã©', 'e')
        .replaceAll('Ãª', 'e')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ã³', 'o')
        .replaceAll('Ã´', 'o')
        .replaceAll('Ãµ', 'o')
        .replaceAll('Ãº', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}
