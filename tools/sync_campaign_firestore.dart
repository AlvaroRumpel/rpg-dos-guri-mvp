import 'dart:convert';
import 'dart:io';

const _defaultProjectId = 'rpg-dos-guri-6b16e';
const _defaultTableId = 'mesa-rpg-dos-guri';

Future<void> main(List<String> args) async {
  final projectId = _argumentValue(args, '--project') ?? _defaultProjectId;
  final tableId = _argumentValue(args, '--table') ?? _defaultTableId;
  final dryRun = args.contains('--dry-run');
  final sync = _CampaignFirestoreSync(
    projectId: projectId,
    tableId: tableId,
    dryRun: dryRun,
  );
  await sync.run();
}

String? _argumentValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

class _CampaignFirestoreSync {
  _CampaignFirestoreSync({
    required this.projectId,
    required this.tableId,
    required this.dryRun,
  });

  final String projectId;
  final String tableId;
  final bool dryRun;
  final _client = HttpClient();

  String get _base =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  Future<void> run() async {
    final powers = await _readAssetList('assets/data/official/powers.json');
    final items = await _readAssetList('assets/data/official/items.json');
    final characters = _campaignCharacters(powers: powers, items: items);

    stdout.writeln(
      '${dryRun ? '[dry-run] ' : ''}Sincronizando $tableId em $projectId...',
    );
    stdout.writeln(
      'Personagens: ${characters.map((item) => item['name']).join(', ')}',
    );

    await _patchDocument('tables/$tableId', {
      'name': 'RPG dos Guri - O Sino',
      'code': 'GURI-1234',
      'pendingPlayerNames': <Object?>[],
      'activeCombatId': null,
    });

    await _markCombatsInactive();
    await _replaceCharacters(characters);
    await _addLog('Dados da campanha O Sino sincronizados a partir do vault.');

    stdout.writeln('Sincronizacao concluida.');
  }

  Future<List<Map<String, dynamic>>> _readAssetList(String path) async {
    final decoded = jsonDecode(await File(path).readAsString());
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, Object?>> _campaignCharacters({
    required List<Map<String, dynamic>> powers,
    required List<Map<String, dynamic>> items,
  }) {
    return [
      {
        'id': 'fodrik-forjardente',
        'name': 'Fodrik Forjardente',
        'race': 'Anão',
        'characterClass': 'Clérigo',
        'level': 1,
        'concept':
            'Anão do clã Pedra Fechada, guerreiro e curador em busca de conter as forças da Ruptura.',
        'attributes': {
          'Forca': 2,
          'Agilidade': -1,
          'Intelecto': -1,
          'Presenca': 3,
          'Vigor': 2,
        },
        'skills': {
          'Atletismo': 0,
          'Furtividade': 0,
          'Percepcao': 1,
          'Natureza': 0,
          'Conhecimento': 1,
          'Influencia': 0,
          'Oficio': 1,
          'Combate': 0,
          'Misticismo': 1,
        },
        'currentHp': 12,
        'armor': 'Armadura pesada',
        'hasShield': false,
        'mainWeapon': 'Martelo de guerra',
        'secondaryItem': 'Símbolo sagrado',
        'accessories': <String>[],
        'powers': [
          _powerEntry(powers, 'Corpo de Pedra', 'fodrik-racial'),
          _powerEntry(powers, 'Cura Sagrada', 'fodrik-cura-sagrada'),
        ],
        'inventory': [
          _itemEntry(items, 'Corda', 1, 'fodrik-corda'),
          _customItem(
            id: 'fodrik-faca-simples',
            name: 'Faca simples',
            quantity: 1,
            description: 'Usar como adaga simples se entrar em combate.',
          ),
          _itemEntry(items, 'Óleo Sagrado', 1, 'fodrik-oleo-sagrado'),
          _itemEntry(items, 'Kit de Curativo', 1, 'fodrik-kit-curativo'),
        ],
        'statuses': <Object?>[],
        'coins': 10,
        'ownerName': 'Thomas',
      },
      {
        'id': 'azog-o-renegado',
        'name': 'Azog o Renegado',
        'race': 'Orc',
        'characterClass': 'Guerreiro',
        'level': 1,
        'concept':
            'Orc exilado que busca recuperar a honra e descobrir quem comandou a morte de Vesha.',
        'attributes': {
          'Forca': 3,
          'Agilidade': -1,
          'Intelecto': -1,
          'Presenca': 2,
          'Vigor': 2,
        },
        'skills': {
          'Atletismo': 0,
          'Furtividade': 0,
          'Percepcao': 0,
          'Natureza': 1,
          'Conhecimento': 0,
          'Influencia': 1,
          'Oficio': 0,
          'Combate': 2,
          'Misticismo': 0,
        },
        'currentHp': 12,
        'armor': 'Armadura pesada',
        'hasShield': false,
        'mainWeapon': 'Espada longa',
        'secondaryItem': 'Espada curta',
        'accessories': <String>[],
        'powers': [
          _powerEntry(powers, 'Fúria Orc', 'azog-racial'),
          _powerEntry(powers, 'Golpe Poderoso', 'azog-golpe-poderoso'),
        ],
        'inventory': [
          _itemEntry(items, 'Poção de Cura', 1, 'azog-pocao-cura'),
          _itemEntry(items, 'Antídoto Simples', 1, 'azog-antidoto'),
          _customItem(
            id: 'azog-corrente-gancho',
            name: 'Corrente com gancho',
            quantity: 1,
            description: 'Corrente de 3 m anotada na ficha da campanha.',
          ),
          _itemEntry(items, 'Kit de Curativo', 1, 'azog-kit-curativo'),
        ],
        'statuses': <Object?>[],
        'coins': 20,
        'ownerName': 'Joazinho das Guria',
      },
      {
        'id': 'rodrik-thompson',
        'name': 'Rodrik Thompson',
        'race': 'Anão',
        'characterClass': 'Guerreiro',
        'level': 1,
        'concept':
            'Anão barbudo, calvo, acima do peso, com armadura média e manto de pele envelhecido.',
        'attributes': {
          'Forca': 0,
          'Agilidade': 0,
          'Intelecto': 0,
          'Presenca': 0,
          'Vigor': 0,
        },
        'skills': {
          'Atletismo': 0,
          'Furtividade': 0,
          'Percepcao': 0,
          'Natureza': 0,
          'Conhecimento': 0,
          'Influencia': 0,
          'Oficio': 0,
          'Combate': 0,
          'Misticismo': 0,
        },
        'currentHp': 10,
        'armor': 'Armadura média',
        'hasShield': false,
        'mainWeapon': 'Soco, chute ou arma improvisada leve',
        'secondaryItem': 'Soco, chute ou arma improvisada leve',
        'accessories': ['Manto de pele'],
        'powers': [
          _powerEntry(powers, 'Corpo de Pedra', 'rodrik-racial'),
          _powerEntry(powers, 'Golpe Poderoso', 'rodrik-golpe-poderoso'),
        ],
        'inventory': <Object?>[],
        'statuses': [
          {
            'id': 'rodrik-ficha-incompleta',
            'name': 'Ficha incompleta',
            'type': 'Narrativo',
            'description':
                'Ficha no vault esta como rascunho; classe, atributos, pericias e inventario precisam ser confirmados.',
            'duration': null,
            'visibleToPlayer': true,
          },
        ],
        'coins': 0,
        'ownerName': 'Theo',
      },
    ];
  }

  Map<String, Object?> _powerEntry(
    List<Map<String, dynamic>> powers,
    String name,
    String id,
  ) {
    final template = _findByName(powers, name);
    return {
      'id': id,
      'name': template?['name'] ?? name,
      'type': template?['type'] ?? 'Poder',
      'description': template?['description'] ?? '',
      'suggestedTest': template?['suggestedTest'] ?? 'Conforme situação',
      'effect': template?['effect'] ?? '',
      'usageLimit': template?['usageLimit'] ?? 'free',
      'used': false,
    };
  }

  Map<String, Object?> _itemEntry(
    List<Map<String, dynamic>> items,
    String name,
    int quantity,
    String id,
  ) {
    final template = _findByName(items, name);
    if (template == null) {
      return _customItem(
        id: id,
        name: name,
        quantity: quantity,
        description: 'Item anotado na ficha da campanha.',
      );
    }
    return {
      'id': id,
      'name': template['name'] ?? name,
      'type': template['type'] ?? 'Item util',
      'quantity': quantity,
      'description': template['description'] ?? '',
      'roll': template['roll'],
      'fixedBonus': template['fixedBonus'] ?? 0,
      'effectKind': template['effectKind'],
    };
  }

  Map<String, Object?> _customItem({
    required String id,
    required String name,
    required int quantity,
    required String description,
  }) {
    return {
      'id': id,
      'name': name,
      'type': 'Item util',
      'quantity': quantity,
      'description': description,
      'roll': null,
      'fixedBonus': 0,
      'effectKind': null,
    };
  }

  Map<String, dynamic>? _findByName(
    List<Map<String, dynamic>> values,
    String name,
  ) {
    for (final value in values) {
      if (_canonical(value['name'] as String? ?? '') == _canonical(name)) {
        return value;
      }
    }
    return null;
  }

  Future<void> _replaceCharacters(List<Map<String, Object?>> characters) async {
    final existing = await _listDocuments('tables/$tableId/characters');
    for (final document in existing) {
      final name = document['name'] as String? ?? '';
      final id = name.split('/').last;
      await _deleteDocument('tables/$tableId/characters/$id');
    }
    for (final character in characters) {
      final id = character['id']! as String;
      final data = Map<String, Object?>.from(character)..remove('id');
      await _patchDocument('tables/$tableId/characters/$id', data);
    }
  }

  Future<void> _markCombatsInactive() async {
    final combats = await _listDocuments('tables/$tableId/combats');
    for (final document in combats) {
      final name = document['name'] as String? ?? '';
      final id = name.split('/').last;
      await _patchDocument('tables/$tableId/combats/$id', {
        'active': false,
        'round': 1,
      });
    }
  }

  Future<List<Map<String, dynamic>>> _listDocuments(String path) async {
    if (dryRun) {
      stdout.writeln('[dry-run] GET $path');
      return const [];
    }
    final response = await _request('GET', '$_base/$path');
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (body is! Map || body['documents'] is! List) return const [];
    return (body['documents'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _patchDocument(String path, Map<String, Object?> data) async {
    if (dryRun) {
      stdout.writeln('[dry-run] PATCH $path');
      return;
    }
    await _request(
      'PATCH',
      '$_base/$path',
      body: jsonEncode({'fields': _firestoreFields(data)}),
    );
  }

  Future<void> _deleteDocument(String path) async {
    if (dryRun) {
      stdout.writeln('[dry-run] DELETE $path');
      return;
    }
    await _request('DELETE', '$_base/$path');
  }

  Future<void> _addLog(String message) async {
    if (dryRun) {
      stdout.writeln('[dry-run] POST log: $message');
      return;
    }
    await _request(
      'POST',
      '$_base/tables/$tableId/logs',
      body: jsonEncode({
        'fields': _firestoreFields({
          'message': message,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        }),
      }),
    );
  }

  Future<_Response> _request(String method, String url, {String? body}) async {
    final request = await _client.openUrl(method, Uri.parse(url));
    request.headers.contentType = ContentType.json;
    if (body != null) request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        '$method $url falhou com ${response.statusCode}: $responseBody',
      );
    }
    return _Response(response.statusCode, responseBody);
  }
}

class _Response {
  const _Response(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

Map<String, Object?> _firestoreFields(Map<String, Object?> data) {
  return {
    for (final entry in data.entries) entry.key: _firestoreValue(entry.value),
  };
}

Map<String, Object?> _firestoreValue(Object? value) {
  if (value == null) return {'nullValue': null};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': '$value'};
  if (value is num) return {'doubleValue': value};
  if (value is String && _looksLikeTimestamp(value)) {
    return {'timestampValue': value};
  }
  if (value is String) return {'stringValue': value};
  if (value is List) {
    return {
      'arrayValue': {
        if (value.isNotEmpty)
          'values': [for (final item in value) _firestoreValue(item)],
      },
    };
  }
  if (value is Map) {
    return {
      'mapValue': {
        'fields': _firestoreFields(Map<String, Object?>.from(value)),
      },
    };
  }
  return {'stringValue': '$value'};
}

bool _looksLikeTimestamp(String value) {
  return RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(value);
}

String _canonical(String value) {
  return value
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
