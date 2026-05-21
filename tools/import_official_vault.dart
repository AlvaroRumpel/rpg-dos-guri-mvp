import 'dart:convert';
import 'dart:io';

const _defaultVaultPath = r'E:\Obsidian\RPG dos Guri\90 Fontes Oficiais';
const _outputPath = 'assets/data/official';

const _raceInfo = {
  'Humano': (
    identity: 'Versatilidade e força de vontade',
    power: 'Determinação Humana',
    description:
        'Depois de rolar um teste importante e antes da consequência final, soma +2 ao resultado.',
    effect: 'Soma +2 em um teste importante',
    limit: 'session',
  ),
  'Elfo': (
    identity: 'Graça, memória antiga e reflexos rápidos',
    power: 'Reflexo Élfico',
    description:
        'Quando um inimigo acertar um ataque contra o elfo, força nova rolagem e fica com o novo resultado.',
    effect: 'Força nova rolagem contra um ataque recebido',
    limit: 'combat',
  ),
  'Anão': (
    identity: 'Resistência, honra e ligação com pedra e metal',
    power: 'Corpo de Pedra',
    description: 'Quando sofrer dano, pode reduzir esse dano em 1d4 + 1.',
    effect: 'Reduz dano recebido em 1d4 + 1',
    limit: 'combat',
  ),
  'Orc': (
    identity: 'Força bruta, instinto e presença intimidadora',
    power: 'Fúria Orc',
    description:
        'Depois de acertar um ataque corpo a corpo, pode causar +1d4 de dano.',
    effect: 'Causa +1d4 de dano ao acertar corpo a corpo',
    limit: 'combat',
  ),
};

const _classRoles = {
  'Guerreiro': 'Linha de frente e dano físico',
  'Ladino': 'Mobilidade, furtividade e oportunismo',
  'Mago': 'Magia arcana, controle e utilidade',
  'Clérigo': 'Cura, fé, proteção e suporte',
};

Future<void> main(List<String> args) async {
  final vaultPath = _argumentValue(args, '--vault') ?? _defaultVaultPath;
  final vault = Directory(vaultPath);
  if (!vault.existsSync()) {
    stderr.writeln('Vault oficial não encontrado: $vaultPath');
    exitCode = 1;
    return;
  }

  final racesClasses = await _read(
    vault,
    'livro_racas_classes_rpg_dos_guri.md',
  );
  final grimoire = await _read(vault, 'grimorio_rpg_dos_guri_v_01.md');
  final equipment = await _read(vault, 'livro_armas_itens_rpg_dos_guri.md');
  final monsters = await _read(vault, 'livro_monstros_rpg_dos_guri.md');

  final output = Directory(_outputPath)..createSync(recursive: true);
  final races = _buildRaces(racesClasses);
  final classes = _buildClasses(racesClasses);
  final progression = _buildProgression(racesClasses);
  final spells = _buildSpells(grimoire);
  final divinePowers = _buildDivinePowers(grimoire);
  final rituals = _buildRituals(grimoire);
  final allEquipment = _buildEquipment(equipment);
  final items = _buildItems(equipment);
  final starterKits = _buildStarterKits(equipment);
  final monsterTemplates = _buildMonsters(monsters);

  await _write(output, 'races.json', races);
  await _write(output, 'classes.json', classes);
  await _write(output, 'progression.json', progression);
  await _write(output, 'spells.json', spells);
  await _write(output, 'rituals.json', rituals);
  await _write(output, 'powers.json', [
    ...races.map(_racePower),
    ...progression.map(_progressionPower),
    ...divinePowers,
  ]);
  await _write(output, 'equipment.json', allEquipment);
  await _write(output, 'items.json', items);
  await _write(output, 'starter_kits.json', starterKits);
  await _write(output, 'monsters.json', monsterTemplates);

  stdout.writeln('Biblioteca oficial gerada em $_outputPath.');
  stdout.writeln(
    'Raças ${races.length}, classes ${classes.length}, progressões ${progression.length}, '
    'magias ${spells.length}, rituais ${rituals.length}, poderes ${divinePowers.length}, '
    'equipamentos ${allEquipment.length}, itens ${items.length}, kits ${starterKits.length}, '
    'monstros ${monsterTemplates.length}.',
  );
}

String? _argumentValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

Future<String> _read(Directory vault, String name) {
  final file = File('${vault.path}${Platform.pathSeparator}$name');
  return file.readAsString(encoding: utf8);
}

Future<void> _write(Directory output, String name, Object data) async {
  const encoder = JsonEncoder.withIndent('  ');
  final file = File('${output.path}${Platform.pathSeparator}$name');
  await file.writeAsString('${encoder.convert(data)}\n', encoding: utf8);
}

List<Map<String, Object?>> _buildRaces(String source) {
  return [
    for (final entry in _raceInfo.entries)
      {
        'id': _slug(entry.key),
        'name': entry.key,
        'identity': entry.value.identity,
        'powerName': entry.value.power,
        'powerDescription': entry.value.description,
        'powerEffect': entry.value.effect,
        'usageLimit': entry.value.limit,
        'origin': 'Raça',
        'actionCost': _raceActionCost(entry.key),
        'roll': _firstRoll(entry.value.effect)?.$1,
        'damage': _damageFromText(entry.value.effect),
        'healing': _healingFromText(entry.value.effect),
        'notes': _cleanMarkdown(
          _between(
            source,
            '# ${_raceNumber(entry.key)}. ${entry.key}',
            '# ${_raceNumber(entry.key) + 1}.',
          ),
        ),
        'source': 'Livro de Raças e Classes > ${entry.key}',
      },
  ];
}

List<Map<String, Object?>> _buildClasses(String source) {
  final skillsTable = _tableAfter(source, '## 8.2 Perícias de classe');
  final skillsByClass = {
    for (final row in skillsTable)
      row['Classe'] ?? '': _splitList(row['Perícias de classe'] ?? ''),
  };
  return [
    for (final entry in _classRoles.entries)
      {
        'id': _slug(entry.key),
        'name': entry.key,
        'role': entry.value,
        'skills': skillsByClass[entry.key] ?? const <String>[],
        'initialPowerName': _initialPowerName(source, entry.key),
        'description': _firstParagraph(
          _between(
            source,
            '# ${_classNumber(entry.key)}. ${entry.key}',
            '# ${_classNumber(entry.key) + 1}.',
          ),
        ),
        'source': 'Livro de Raças e Classes > ${entry.key}',
      },
  ];
}

List<Map<String, Object?>> _buildProgression(String source) {
  final result = <Map<String, Object?>>[];
  for (final className in _classRoles.keys) {
    final rows = _tableAfter(source, 'Progressão do $className');
    final classSection = _between(
      source,
      '# ${_classNumber(className)}. $className',
      '# ${_classNumber(className) + 1}.',
    );
    for (final row in rows) {
      final level = int.tryParse(row['Nível'] ?? '') ?? 1;
      final name = row['Habilidade'] ?? 'Habilidade';
      final summary = row['Resumo'] ?? '';
      final detail = _detailBlockForLevel(classSection, level, name);
      result.add({
        'id': '${_slug(className)}-$level',
        'characterClass': className,
        'level': level,
        'name': name,
        'description': summary,
        'usageLimit': _usageLimitFromText('$summary $detail'),
        'origin': 'Classe',
        'actionCost': _actionCostFromText('$summary $detail'),
        'roll': _firstRoll('$summary $detail')?.$1,
        'damage': _damageFromText('$summary $detail'),
        'healing': _healingFromText('$summary $detail'),
        'notes': detail,
        'source': 'Livro de Raças e Classes > $className > Nível $level',
      });
    }
  }
  return result;
}

List<Map<String, Object?>> _buildSpells(String source) {
  final spellSection = _between(
    source,
    '# 6. Magias simples básicas',
    '# 9. Poderes divinos',
  );
  return _spellLikeEntries(spellSection, origin: 'Grimório', power: false);
}

List<Map<String, Object?>> _buildDivinePowers(String source) {
  final powerSection = _between(
    source,
    '# 9. Poderes divinos',
    '# 10. Rituais',
  );
  return _spellLikeEntries(powerSection, origin: 'Poder divino', power: true);
}

List<Map<String, Object?>> _spellLikeEntries(
  String section, {
  required String origin,
  required bool power,
}) {
  final entries = <Map<String, Object?>>[];
  final heading = RegExp(r'^##\s+\d+\.\s+(.+)$', multiLine: true);
  final matches = heading.allMatches(section).toList();
  for (var index = 0; index < matches.length; index += 1) {
    final match = matches[index];
    final name = match.group(1)!.trim();
    final end = index + 1 < matches.length ? matches[index + 1].start : null;
    final block = section.substring(match.end, end);
    final row = _fieldMap(block);
    if (row.isEmpty) continue;
    final type = row['Tipo'] ?? (power ? 'Poder divino' : 'Magia');
    final damage = row['Dano'] ?? row['Dano/Cura'];
    final healing = row['Cura'] ?? row['Dano/Cura'];
    final effect = row['Efeito'] ?? damage ?? healing ?? 'Conforme descrição';
    final extra = _joinPresent([
      row['Efeito extra'],
      if (row['Dificuldade'] != null) 'Dificuldade: ${row['Dificuldade']}',
      if (row['Dano no nível 9'] != null)
        'Dano no nível 9: ${row['Dano no nível 9']}',
    ]);
    final limit = row['Limite'] ?? type;
    entries.add({
      'id': _slug(name),
      'name': name,
      if (power) 'type': type else 'tier': _spellTier(type),
      'description': _joinPresent([
        if (row['Tema'] != null) 'Tema: ${row['Tema']}',
        if (row['Uso'] != null) 'Uso: ${row['Uso']}',
        if (row['Alcance'] != null) 'Alcance: ${row['Alcance']}',
        if (row['Duração'] != null) 'Duração: ${row['Duração']}',
      ]),
      'suggestedTest': row['Teste'] ?? 'Conforme situação',
      'effect': effect,
      'usageLimit': _usageLimitFromText(limit),
      'origin': origin,
      'actionCost': row['Uso'],
      'range': row['Alcance'],
      'duration': row['Duração'],
      'roll': _firstRoll(row['Teste'] ?? '')?.$1,
      'damage': damage,
      'healing': healing,
      'extraEffect': extra,
      'notes': _sectionNotes(block),
      'source': 'Grimório > $name',
    });
  }
  return entries;
}

List<Map<String, Object?>> _buildRituals(String source) {
  final rolls = _tableAfter(source, '## 10.2 Rolagens de ritual');
  final difficulties = _tableAfter(source, '## 10.3 Dificuldade de ritual');
  final difficultyText = difficulties
      .map((row) => '${row['Tipo de ritual']}: ${row['Dificuldade']}')
      .join('; ');
  return [
    for (final row in rolls)
      {
        'id': _slug(row['Ritual']!),
        'name': row['Ritual'],
        'suggestedRoll': row['Rolagem sugerida'],
        'description':
            'Ritual fora de combate. O mestre define efeito, risco e consequência.',
        'difficulty': difficultyText,
        'origin': 'Ritual',
        'actionCost': 'Fora de combate',
        'roll': _firstRoll(row['Rolagem sugerida'] ?? '')?.$1,
        'effect': 'Efeito definido pelo mestre conforme a cena.',
        'extraEffect': 'Falhas podem gerar consequência narrativa.',
        'source': 'Grimório > Rituais',
      },
  ];
}

List<Map<String, Object?>> _buildEquipment(String source) {
  final equipment = <Map<String, Object?>>[];
  for (final row in _tableAfter(source, '# 6. Lista geral de armas comuns')) {
    equipment.add({
      'id': _slug(row['Arma']!),
      'name': row['Arma'],
      'category': 'weapon',
      'description': 'Arma comum oficial.',
      'damage': row['Dano'],
      'attribute': row['Atributo usado'],
      'properties': _splitList(row['Propriedade'] ?? ''),
      'recommendedClasses': _splitList(row['Classes mais indicadas'] ?? ''),
      'origin': 'Arma comum',
      'roll': row['Dano'],
      'source': 'Livro de Armas e Itens > Armas comuns',
    });
  }
  for (final row in _tableAfter(source, '# 8. Armas especiais simples')) {
    equipment.add({
      'id': _slug(row['Arma']!),
      'name': row['Arma'],
      'category': 'weapon',
      'description': 'Base: ${row['Base']}. ${row['Efeito']}',
      'properties': const ['Especial'],
      'origin': 'Arma especial',
      'usageLimit': _usageLimitFromText(row['Efeito'] ?? ''),
      'effect': row['Efeito'],
      'source': 'Livro de Armas e Itens > Armas especiais simples',
    });
  }
  for (final row in _tableAfter(source, '## 10.1 Escudos comuns')) {
    equipment.add({
      'id': _slug(row['Escudo']!),
      'name': row['Escudo'],
      'category': 'shield',
      'description': row['Observação'],
      'defenseBonus': _signedInt(row['Defesa']),
      'origin': 'Escudo comum',
      'source': 'Livro de Armas e Itens > Escudos comuns',
    });
  }
  for (final row in _tableAfter(source, '## 10.2 Escudos especiais')) {
    equipment.add({
      'id': _slug(row['Escudo']!),
      'name': row['Escudo'],
      'category': 'shield',
      'description': row['Efeito'],
      'defenseBonus': 1,
      'origin': 'Escudo especial',
      'usageLimit': _usageLimitFromText(row['Efeito'] ?? ''),
      'effect': row['Efeito'],
      'source': 'Livro de Armas e Itens > Escudos especiais',
    });
  }
  for (final row in _tableAfter(source, '# 11. Armaduras comuns')) {
    equipment.add({
      'id': _slug(row['Proteção']!),
      'name': row['Proteção'],
      'category': 'armor',
      'description': row['Observação'],
      'baseDefense': int.tryParse(row['Defesa base'] ?? '') ?? 10,
      'origin': 'Armadura comum',
      'source': 'Livro de Armas e Itens > Armaduras comuns',
    });
  }
  for (final heading in const [
    '## 13.1 Anéis',
    '## 13.2 Colares e amuletos',
    '## 13.3 Braceletes, cintos e broches',
  ]) {
    for (final row in _tableAfter(source, heading)) {
      final name = row.values.first;
      final effect = row.values.length > 1 ? row.values.elementAt(1) : '';
      equipment.add({
        'id': _slug(name),
        'name': name,
        'category': 'accessory',
        'description': effect,
        'origin': 'Acessório',
        'usageLimit': _usageLimitFromText(effect),
        'effect': effect,
        'source': 'Livro de Armas e Itens > Acessórios',
      });
    }
  }
  return equipment;
}

List<Map<String, Object?>> _buildItems(String source) {
  final items = <Map<String, Object?>>[];
  for (final row in _tableAfter(source, '# 14. Itens consumíveis')) {
    final name = row['Item']!;
    final effect = row['Efeito']!;
    final parsedRoll = _firstRoll(effect);
    items.add({
      'id': _slug(name),
      'name': name,
      'type': 'Consumível',
      'description': effect,
      'defaultQuantity': 1,
      'roll': parsedRoll?.$1,
      'fixedBonus': parsedRoll?.$2 ?? 0,
      'effectKind': _effectKind(name, effect),
      'origin': 'Item consumível',
      'actionCost': 'Ação ou conforme a cena',
      'extraEffect': _damageFromText(effect) ?? _healingFromText(effect),
      'source': 'Livro de Armas e Itens > Itens consumíveis',
    });
  }
  const useful = {
    'Tocha': 'Iluminação simples para uma cena ou exploração curta.',
    'Corda': 'Corda comum para escalada, amarras e improvisos.',
    'Ferramentas simples': 'Ferramentas úteis para ações de Ofício.',
    'Mochila': 'Carrega itens comuns de aventura.',
    'Flechas ou virotes': 'Munição narrativa para arco ou besta.',
  };
  for (final entry in useful.entries) {
    items.add({
      'id': _slug(entry.key),
      'name': entry.key,
      'type': 'Item útil',
      'description': entry.value,
      'defaultQuantity': entry.key == 'Tocha' ? 2 : 1,
      'fixedBonus': 0,
      'origin': 'Item útil',
      'source': 'Livro de Armas e Itens > Itens úteis',
    });
  }
  return items;
}

List<Map<String, Object?>> _buildStarterKits(String source) {
  final section = _between(source, '# 15. Kits iniciais sugeridos', '# 16.');
  final heading = RegExp(r'^##\s+15\.\d+\s+(.+)$', multiLine: true);
  final matches = heading.allMatches(section).toList();
  final kits = <Map<String, Object?>>[];
  for (var index = 0; index < matches.length; index += 1) {
    final match = matches[index];
    final name = match.group(1)!.trim();
    final end = index + 1 < matches.length ? matches[index + 1].start : null;
    final block = section.substring(match.end, end);
    final items = RegExp(
      r'^-\s+(.+?);?$',
      multiLine: true,
    ).allMatches(block).map((item) => item.group(1)!.trim()).toList();
    kits.add({
      'id': _slug(name),
      'name': name,
      'characterClass': _classFromKitName(name),
      'items': items,
      'source': 'Livro de Armas e Itens > Kits iniciais',
    });
  }
  return kits;
}

List<Map<String, Object?>> _buildMonsters(String source) {
  final section = _between(source, '# 8. Monstros muito fracos', '# 15.');
  final heading = RegExp(r'^##\s+\d+\.\d+\s+(.+)$', multiLine: true);
  final matches = heading.allMatches(section).toList();
  final monsters = <Map<String, Object?>>[];
  for (var index = 0; index < matches.length; index += 1) {
    final match = matches[index];
    final name = match.group(1)!.trim();
    final end = index + 1 < matches.length ? matches[index + 1].start : null;
    final block = section.substring(match.end, end);
    final row = _fieldMap(block);
    if (row.isEmpty) continue;
    monsters.add({
      'id': _slug(name),
      'name': name,
      'category': row['Categoria'] ?? 'Monstro',
      'defense': int.tryParse(row['Defesa'] ?? '') ?? 10,
      'maxHp': int.tryParse(row['Vida'] ?? '') ?? 1,
      'attack': row['Ataque'] ?? '1d20',
      'damage': row['Dano'] ?? '1',
      'movement': row['Movimento'] ?? 'Normal',
      'instinct': row['Instinto'] ?? '',
      'special': _specialHeading(block),
      'description': row['Função'] ?? '',
      'behavior': _subsection(block, 'Comportamento'),
      'encounterUse': _subsection(block, 'Uso em encontros'),
      'rewards': _subsection(block, 'Recompensas ou pistas'),
      'source': 'Livro de Monstros > $name',
    });
  }
  return monsters;
}

Map<String, Object?> _racePower(Map<String, Object?> race) {
  return {
    'id': '${race['id']}-racial',
    'name': race['powerName'],
    'type': 'Poder racial',
    'description': race['powerDescription'],
    'suggestedTest': 'Conforme situação',
    'effect': race['powerEffect'],
    'usageLimit': race['usageLimit'],
    'origin': race['origin'],
    'actionCost': race['actionCost'],
    'roll': race['roll'],
    'damage': race['damage'],
    'healing': race['healing'],
    'notes': race['notes'],
    'source': race['source'],
  };
}

Map<String, Object?> _progressionPower(Map<String, Object?> progression) {
  return {
    'id': progression['id'],
    'name': progression['name'],
    'type': 'Habilidade de classe',
    'description': progression['description'],
    'suggestedTest': 'Conforme situação',
    'effect': progression['description'],
    'usageLimit': progression['usageLimit'],
    'origin': '${progression['characterClass']} nível ${progression['level']}',
    'actionCost': progression['actionCost'],
    'roll': progression['roll'],
    'damage': progression['damage'],
    'healing': progression['healing'],
    'notes': progression['notes'],
    'source': progression['source'],
  };
}

List<Map<String, String>> _tableAfter(String source, String heading) {
  final index = source.indexOf(heading);
  if (index == -1) return const [];
  return _firstTable(source.substring(index));
}

List<Map<String, String>> _firstTable(String source) {
  final lines = const LineSplitter().convert(source);
  final tableLines = <String>[];
  var collecting = false;
  for (final line in lines) {
    if (line.trim().startsWith('|')) {
      collecting = true;
      tableLines.add(line);
      continue;
    }
    if (collecting) break;
  }
  if (tableLines.length < 2) return const [];
  final headers = _splitRow(tableLines.first);
  final rows = <Map<String, String>>[];
  for (final line in tableLines.skip(2)) {
    final cells = _splitRow(line);
    if (cells.length != headers.length) continue;
    rows.add({
      for (var index = 0; index < headers.length; index += 1)
        headers[index]: cells[index],
    });
  }
  return rows;
}

Map<String, String> _fieldMap(String source) {
  final table = _firstTable(source);
  if (table.isEmpty) return const {};
  final first = table.first;
  if (first.containsKey('Campo') && first.containsKey('Informação')) {
    return {
      for (final row in table)
        if (row['Campo'] != null) row['Campo']!: row['Informação'] ?? '',
    };
  }
  return first;
}

List<String> _splitRow(String line) {
  final trimmed = line.trim();
  final withoutEdges = trimmed.substring(1, trimmed.length - 1);
  return withoutEdges.split('|').map((cell) => cell.trim()).toList();
}

String _between(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  if (start == -1) return '';
  final end = source.indexOf(endMarker, start + startMarker.length);
  return source.substring(start, end == -1 ? source.length : end);
}

String _subsection(String source, String heading) {
  final start = source.indexOf('### $heading');
  if (start == -1) return '';
  final afterHeading = source.indexOf('\n', start);
  if (afterHeading == -1) return '';
  final next = source.indexOf('\n### ', afterHeading + 1);
  return _cleanMarkdown(
    source.substring(afterHeading, next == -1 ? source.length : next),
  );
}

String _sectionNotes(String source) {
  return _joinPresent([
    _subsection(source, 'Como funciona'),
    _subsection(source, 'Exemplos de uso'),
    _subsection(source, 'Observações para o mestre'),
  ]);
}

String _detailBlockForLevel(String source, int level, String name) {
  final heading = '### Nível $level — $name';
  final start = source.indexOf(heading);
  if (start == -1) return '';
  final next = source.indexOf('\n### Nível ', start + heading.length);
  return _cleanMarkdown(
    source.substring(start + heading.length, next == -1 ? source.length : next),
  );
}

String _firstParagraph(String source) {
  final cleaned = _cleanMarkdown(source);
  if (cleaned.isEmpty) return '';
  return cleaned.split('\n').firstWhere((line) => line.trim().isNotEmpty);
}

String _cleanMarkdown(String value) {
  return const LineSplitter()
      .convert(value)
      .map((line) => line.trim())
      .where((line) {
        if (line.isEmpty) return false;
        if (line.startsWith('#')) return false;
        if (line.startsWith('---')) return false;
        if (line.startsWith('>')) return false;
        if (line.startsWith('|')) return false;
        if (line.startsWith('### Ilustração')) return false;
        if (line.startsWith('### Prompt')) return false;
        return true;
      })
      .map((line) => line.replaceFirst(RegExp(r'^-\s+'), ''))
      .join('\n');
}

String _joinPresent(Iterable<String?> values) {
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join('. ');
}

String _specialHeading(String block) {
  final match = RegExp(
    r'^### Habilidade especial\s+—\s+(.+)$',
    multiLine: true,
  ).firstMatch(block);
  return match?.group(1)?.trim() ?? '';
}

String _spellTier(String type) {
  final lower = type.toLowerCase();
  if (lower.contains('forte')) return 'Magia forte';
  return 'Magia simples';
}

String _usageLimitFromText(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('sess')) return 'session';
  if (lower.contains('descanso longo')) return 'longRest';
  if (lower.contains('combate') || lower.contains('forte')) return 'combat';
  return 'free';
}

String? _actionCostFromText(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('reação')) return 'Reação';
  if (lower.contains('ação')) return 'Ação';
  if (lower.contains('fora de combate')) return 'Fora de combate';
  return null;
}

String? _raceActionCost(String race) {
  return switch (race) {
    'Elfo' => 'Reação',
    'Humano' || 'Anão' || 'Orc' => 'Ao disparar o efeito',
    _ => null,
  };
}

String? _damageFromText(String text) {
  final lower = text.toLowerCase();
  if (!lower.contains('dano')) return null;
  return _firstRoll(text)?.$1 ?? _firstNumberEffect(text);
}

String? _healingFromText(String text) {
  final lower = text.toLowerCase();
  if (!lower.contains('cura') &&
      !lower.contains('recupera') &&
      !lower.contains('vida')) {
    return null;
  }
  return _firstRoll(text)?.$1 ?? _firstNumberEffect(text);
}

String? _firstNumberEffect(String text) {
  final match = RegExp(r'([+-]?\d+\s*(?:de\s+\w+)?)').firstMatch(text);
  return match?.group(1)?.trim();
}

List<String> _splitList(String value) {
  return value
      .replaceAll(' e ', ',')
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

int _signedInt(String? value) {
  if (value == null) return 0;
  return int.tryParse(value.replaceAll('+', '').trim()) ?? 0;
}

(String, int)? _firstRoll(String text) {
  final match = RegExp(r'(\d+d\d+)(?:\s*\+\s*(\d+))?').firstMatch(text);
  if (match == null) return null;
  return (match.group(1)!, int.tryParse(match.group(2) ?? '0') ?? 0);
}

String? _effectKind(String name, String effect) {
  final lower = '$name $effect'.toLowerCase();
  if (lower.contains('cura') || lower.contains('recupera')) return 'heal';
  if (lower.contains('causa') && lower.contains('dano')) return 'damage';
  return null;
}

String _classFromKitName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('guerreiro')) return 'Guerreiro';
  if (lower.contains('ladino')) return 'Ladino';
  if (lower.contains('mago')) return 'Mago';
  if (lower.contains('clérigo')) return 'Clérigo';
  return '';
}

String _initialPowerName(String source, String className) {
  final rows = _tableAfter(source, 'Progressão do $className');
  if (rows.isEmpty) return '';
  return rows.first['Habilidade'] ?? '';
}

int _raceNumber(String race) {
  return switch (race) {
    'Humano' => 4,
    'Elfo' => 5,
    'Anão' => 6,
    'Orc' => 7,
    _ => 0,
  };
}

int _classNumber(String className) {
  return switch (className) {
    'Guerreiro' => 9,
    'Ladino' => 10,
    'Mago' => 11,
    'Clérigo' => 12,
    _ => 0,
  };
}

String _slug(String value) {
  final normalized = value
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
      .replaceAll('ú', 'u');
  return normalized
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'(^-|-$)'), '');
}
