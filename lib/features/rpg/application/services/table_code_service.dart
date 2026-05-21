class TableCodeService {
  const TableCodeService._();

  static String normalize(String rawCode) {
    final cleaned = rawCode.trim().toUpperCase().replaceAll(' ', '-');
    if (cleaned.isEmpty) return '';
    if (cleaned.startsWith('GURI-')) return cleaned;
    return 'GURI-$cleaned';
  }

  static String tableIdFromCode(String code) {
    final slug = code.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
    return 'table-${slug.replaceAll(RegExp('-+'), '-').replaceAll(RegExp(r'(^-|-$)'), '')}';
  }
}
