part of '../shell/session_shell.dart';

String _joinStats(Map<String, int> values) {
  return values.entries
      .map(
        (entry) => '${entry.key} ${entry.value >= 0 ? '+' : ''}${entry.value}',
      )
      .join(', ');
}

String _officialValue(String? current, List<String> options, String fallback) {
  if (current != null) {
    for (final option in options) {
      if (_sameOptionName(option, current)) return option;
    }
  }
  if (fallback.isNotEmpty) {
    for (final option in options) {
      if (_sameOptionName(option, fallback)) return option;
    }
  }
  if (options.isNotEmpty) return options.first;
  return fallback;
}

List<String> _ensureDropdownOptions(List<String> options, String selected) {
  if (options.contains(selected)) return options;
  if (selected.isEmpty) return options;
  return [selected, ...options];
}

Widget _dropdownLabel(String value, {String emptyLabel = 'Nenhum'}) {
  return Text(
    value.isEmpty ? emptyLabel : value,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

List<DropdownMenuItem<String>> _stringDropdownItems(
  Iterable<String> values, {
  String emptyLabel = 'Nenhum',
}) {
  return [
    for (final value in values)
      DropdownMenuItem(
        value: value,
        child: _dropdownLabel(value, emptyLabel: emptyLabel),
      ),
  ];
}

bool _sameOptionName(String left, String right) {
  return _canonicalOptionName(left) == _canonicalOptionName(right);
}

String _canonicalOptionName(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ã', 'a')
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

const _attributeNames = [
  'Forca',
  'Agilidade',
  'Intelecto',
  'Presenca',
  'Vigor',
];

const _skillNames = [
  'Atletismo',
  'Furtividade',
  'Percepcao',
  'Natureza',
  'Conhecimento',
  'Influencia',
  'Oficio',
  'Combate',
  'Misticismo',
];

Map<String, int> _parseStats(Map<String, TextEditingController> controllers) {
  return {
    for (final entry in controllers.entries)
      entry.key: int.tryParse(entry.value.text) ?? 0,
  };
}

String? _firstInvalidStat(Map<String, int> values, int max) {
  for (final entry in values.entries) {
    if (entry.value > max) return entry.key;
  }
  return null;
}

T? _firstOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}

String _joinDialogDetails(Iterable<String?> values) {
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' - ');
}
