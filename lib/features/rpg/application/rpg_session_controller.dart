import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/official_library_repository.dart';
import '../data/rpg_repositories.dart';
import '../domain/domain.dart';
import 'services/character_factory.dart';
import 'services/character_power_reconciliation_service.dart';
import 'services/character_progression_service.dart';
import 'services/combat_service.dart';
import 'services/official_name_matcher.dart';
import 'services/performance_trace.dart';
import 'services/table_code_service.dart';

class RpgSessionController extends ChangeNotifier {
  RpgSessionController.seeded()
    : table = const RpgTable(
        id: 'mesa-rpg-dos-guri',
        name: 'RPG dos Guri',
        code: 'GURI-1234',
      ),
      characters = CharacterFactory.seedCharacters(),
      races = const [],
      classes = const [],
      monsters = const [],
      powerLibrary = const [],
      spellLibrary = const [],
      ritualLibrary = const [],
      itemLibrary = const [],
      equipmentLibrary = const [],
      starterKits = const [],
      classProgression = const [],
      _libraryRepository = OfficialLibraryRepository(),
      _tableRepository = null,
      _characterRepository = null,
      _combatRepository = null,
      _actionLogRepository = null {
    _loadOfficialLibrary();
  }

  RpgSessionController.firestore({
    required TableRepository tableRepository,
    required CharacterRepository characterRepository,
    required CombatRepository combatRepository,
    required ActionLogRepository actionLogRepository,
    OfficialLibraryRepository? libraryRepository,
  }) : table = const RpgTable(
         id: 'mesa-rpg-dos-guri',
         name: 'RPG dos Guri',
         code: 'GURI-1234',
       ),
       characters = CharacterFactory.seedCharacters(),
       races = const [],
       classes = const [],
       monsters = const [],
       powerLibrary = const [],
       spellLibrary = const [],
       ritualLibrary = const [],
       itemLibrary = const [],
       equipmentLibrary = const [],
       starterKits = const [],
       classProgression = const [],
       _libraryRepository = libraryRepository ?? OfficialLibraryRepository(),
       _tableRepository = tableRepository,
       _characterRepository = characterRepository,
       _combatRepository = combatRepository,
       _actionLogRepository = actionLogRepository {
    _loadOfficialLibrary();
    _markCurrentStatePersisted();
    _connectFirestore();
  }

  RpgTable table;
  List<CharacterSheet> characters;
  List<RaceTemplate> races;
  List<ClassTemplate> classes;
  List<MonsterTemplate> monsters;
  List<PowerTemplate> powerLibrary;
  List<SpellTemplate> spellLibrary;
  List<RitualTemplate> ritualLibrary;
  List<ItemTemplate> itemLibrary;
  List<EquipmentTemplate> equipmentLibrary;
  List<StarterKitTemplate> starterKits;
  List<ClassProgressionEntry> classProgression;
  final OfficialLibraryRepository _libraryRepository;
  final TableRepository? _tableRepository;
  final CharacterRepository? _characterRepository;
  final CombatRepository? _combatRepository;
  final ActionLogRepository? _actionLogRepository;
  CombatState? activeCombat;
  UserRole role = UserRole.landing;
  String? selectedCharacterId;
  String? _pendingSelectedCharacterId;
  List<String> pendingPlayerNames = [];
  final List<String> actionLog = [];
  StreamSubscription<RpgTable?>? _tableSubscription;
  StreamSubscription<List<CharacterSheet>>? _characterSubscription;
  StreamSubscription<CombatState?>? _combatSubscription;
  StreamSubscription<List<String>>? _logSubscription;
  Timer? _persistDebounce;
  RpgTable? _persistedTable;
  CombatState? _persistedCombat;
  final Map<String, CharacterSheet> _persistedCharacters = {};
  List<CharacterSheet>? _activeCharactersCache;
  List<CharacterSheet>? _archivedCharactersCache;
  List<CharacterSheet>? _characterCacheSource;
  SharedPreferences? _preferences;
  bool _applyingRemoteState = false;
  bool _remoteTableExists = false;
  bool _masterAuthorized = false;
  Map<String, EquipmentTemplate> _equipmentByName = const {};
  Map<EquipmentCategory, List<EquipmentTemplate>> _equipmentByCategory =
      const {};

  static const _lastTableCodeKey = 'rpg.lastTableCode';
  static const _lastCharacterIdKey = 'rpg.lastCharacterId';
  static const _masterAuthPrefix = 'rpg.masterAuth.';

  List<EquipmentTemplate> get weapons =>
      _equipmentByCategory[EquipmentCategory.weapon] ?? const [];

  List<EquipmentTemplate> get shields =>
      _equipmentByCategory[EquipmentCategory.shield] ?? const [];

  List<EquipmentTemplate> get armors =>
      _equipmentByCategory[EquipmentCategory.armor] ?? const [];

  List<EquipmentTemplate> get accessories =>
      _equipmentByCategory[EquipmentCategory.accessory] ?? const [];

  List<CharacterSheet> get activeCharacters {
    _refreshCharacterCaches();
    return _activeCharactersCache!;
  }

  List<CharacterSheet> get archivedCharacters {
    _refreshCharacterCaches();
    return _archivedCharactersCache!;
  }

  List<PowerUseRequest> get powerUseRequests => table.powerUseRequests;

  bool get hasMasterPin => table.masterPinHash?.isNotEmpty == true;

  bool get masterAuthorized => _masterAuthorized;

  EquipmentTemplate? equipmentByName(String name) {
    return _equipmentByName[OfficialNameMatcher.canonical(name)];
  }

  MonsterTemplate? monsterById(String id) {
    return monsters.where((monster) => monster.id == id).firstOrNull;
  }

  CharacterSheet? characterById(String id) {
    return characters.where((character) => character.id == id).firstOrNull;
  }

  Object? mentionTargetByName(String rawName) {
    final cleaned = rawName.trim();
    if (cleaned.isEmpty) return null;
    final character = activeCharacters
        .where((item) => OfficialNameMatcher.same(item.name, cleaned))
        .firstOrNull;
    if (character != null) return character;
    return table.customNpcs
        .where((item) => OfficialNameMatcher.same(item.name, cleaned))
        .firstOrNull;
  }

  List<Object> mentionSuggestions(String rawQuery, {int limit = 8}) {
    final query = OfficialNameMatcher.canonical(rawQuery);
    bool matches(String name) {
      final canonical = OfficialNameMatcher.canonical(name);
      return query.isEmpty || canonical.contains(query);
    }

    final suggestions = <Object>[
      for (final character in activeCharacters)
        if (matches(character.name)) character,
      for (final npc in table.customNpcs)
        if (npc.name.trim().isNotEmpty && matches(npc.name)) npc,
    ];
    return suggestions.take(limit).toList();
  }

  CharacterSheet? get selectedCharacter {
    if (selectedCharacterId == null) return null;
    for (final character in characters) {
      if (character.id == selectedCharacterId && !character.archived) {
        return character;
      }
    }
    return null;
  }

  Future<void> bootstrap({String? initialTableCode}) async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    final savedCode = preferences.getString(_lastTableCodeKey);
    final code = initialTableCode?.trim().isNotEmpty == true
        ? initialTableCode
        : savedCode;
    if (code != null && code.trim().isNotEmpty) {
      await openTableByCode(code);
    } else {
      await _rememberTable();
    }
    final savedCharacterId = preferences.getString(_lastCharacterIdKey);
    if (savedCharacterId != null &&
        activeCharacters.any((character) => character.id == savedCharacterId)) {
      selectedCharacterId = savedCharacterId;
    } else {
      _pendingSelectedCharacterId = savedCharacterId;
    }
    _masterAuthorized =
        preferences.getBool('$_masterAuthPrefix${table.id}') ?? false;
    notifyListeners();
  }

  Future<void> _loadOfficialLibrary() async {
    try {
      final library = await RpgPerformanceTrace.async(
        'official_library.load',
        _libraryRepository.load,
      );
      races = library.races;
      classes = library.classes;
      monsters = library.monsters;
      powerLibrary = library.powers;
      spellLibrary = library.spells;
      ritualLibrary = library.rituals;
      itemLibrary = library.items;
      equipmentLibrary = library.equipment;
      _indexEquipment();
      starterKits = library.starterKits;
      classProgression = library.progression;
      characters = characters.map(_prepareCharacter).toList();
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Falha ao carregar biblioteca oficial: $error');
      debugPrint('$stackTrace');
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_applyingRemoteState) _schedulePersistChanges();
  }

  @override
  void dispose() {
    _cancelFirestoreSubscriptions();
    _persistDebounce?.cancel();
    super.dispose();
  }

  void _cancelFirestoreSubscriptions() {
    _tableSubscription?.cancel();
    _characterSubscription?.cancel();
    _combatSubscription?.cancel();
    _logSubscription?.cancel();
    _tableSubscription = null;
    _characterSubscription = null;
    _combatSubscription = null;
    _logSubscription = null;
  }

  void _connectFirestore() {
    _tableSubscription = _tableRepository?.watchTable(table.id).listen((
      remoteTable,
    ) {
      if (remoteTable == null) {
        _remoteTableExists = false;
        _persistChanges(forceAll: true);
        return;
      }
      _remoteTableExists = true;
      _applyRemoteState(() {
        table = remoteTable;
        _persistedTable = remoteTable;
        pendingPlayerNames = remoteTable.pendingPlayerNames;
        _masterAuthorized =
            _preferences?.getBool('$_masterAuthPrefix${remoteTable.id}') ??
            false;
      });
    });

    _characterSubscription = _characterRepository
        ?.watchCharacters(table.id)
        .listen((remoteCharacters) {
          if (!_remoteTableExists && remoteCharacters.isEmpty) {
            return;
          }
          _applyRemoteState(() {
            characters = remoteCharacters;
            _persistedCharacters
              ..clear()
              ..addEntries(
                remoteCharacters.map(
                  (character) => MapEntry(character.id, character),
                ),
              );
            final pending = _pendingSelectedCharacterId;
            if (pending != null &&
                activeCharacters.any((character) => character.id == pending)) {
              selectedCharacterId = pending;
              _pendingSelectedCharacterId = null;
            }
          });
        });

    _combatSubscription = _combatRepository?.watchActiveCombat(table.id).listen(
      (remoteCombat) {
        _applyRemoteState(() {
          activeCombat = remoteCombat;
          _persistedCombat = remoteCombat;
          table = table.copyWith(activeCombatId: remoteCombat?.id);
        });
      },
    );

    _logSubscription = _actionLogRepository?.watchRecent(table.id).listen((
      remoteLog,
    ) {
      _applyRemoteState(() {
        actionLog
          ..clear()
          ..addAll(remoteLog);
      });
    });
  }

  void _applyRemoteState(VoidCallback apply) {
    RpgPerformanceTrace.sync('firestore.remote_apply', () {
      _applyingRemoteState = true;
      try {
        apply();
        super.notifyListeners();
      } finally {
        _applyingRemoteState = false;
      }
    });
  }

  void _markCurrentStatePersisted() {
    _persistedTable = table;
    _persistedCombat = activeCombat;
    _persistedCharacters
      ..clear()
      ..addEntries(
        characters.map((character) => MapEntry(character.id, character)),
      );
  }

  void _schedulePersistChanges() {
    if (_tableRepository == null ||
        _characterRepository == null ||
        _combatRepository == null) {
      return;
    }
    _persistDebounce?.cancel();
    _persistDebounce = Timer(
      const Duration(milliseconds: 250),
      _persistChanges,
    );
  }

  Future<void> _persistChanges({bool forceAll = false}) async {
    if (_applyingRemoteState) return;
    final tableRepository = _tableRepository;
    final characterRepository = _characterRepository;
    final combatRepository = _combatRepository;
    if (tableRepository == null ||
        characterRepository == null ||
        combatRepository == null) {
      return;
    }

    await RpgPerformanceTrace.async('firestore.persist_changes', () async {
      final tableToSave = table;
      final combatToSave = activeCombat;
      final charactersToSave = [
        for (final character in characters)
          if (forceAll ||
              !identical(_persistedCharacters[character.id], character))
            character,
      ];
      if (forceAll || !identical(_persistedTable, tableToSave)) {
        await tableRepository.saveTable(tableToSave);
        _persistedTable = tableToSave;
      }
      await Future.wait([
        for (final character in charactersToSave)
          characterRepository.saveCharacter(table.id, character),
      ]);
      for (final character in charactersToSave) {
        _persistedCharacters[character.id] = character;
      }
      if (combatToSave != null &&
          (forceAll || !identical(_persistedCombat, combatToSave))) {
        await combatRepository.saveCombat(table.id, combatToSave);
        _persistedCombat = combatToSave;
      }
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint('Falha ao sincronizar Firestore: $error');
      debugPrint('$stackTrace');
    });
  }

  void _refreshCharacterCaches() {
    if (identical(_characterCacheSource, characters)) return;
    _characterCacheSource = characters;
    _activeCharactersCache = [
      for (final character in characters)
        if (!character.archived) character,
    ];
    _archivedCharactersCache = [
      for (final character in characters)
        if (character.archived) character,
    ];
  }

  void enterAsMaster() {
    role = UserRole.master;
    notifyListeners();
  }

  Future<bool> enterAsMasterWithPin(String pin) async {
    final cleaned = pin.trim();
    if (cleaned.length < 4) return false;
    final hash = _masterPinHash(cleaned, table.id);
    if (!hasMasterPin) {
      table = table.copyWith(masterPinHash: hash);
      _masterAuthorized = true;
      await _rememberMasterAuth();
      _log('PIN domestico do mestre configurado.');
      enterAsMaster();
      return true;
    }
    if (hash != table.masterPinHash) return false;
    _masterAuthorized = true;
    await _rememberMasterAuth();
    enterAsMaster();
    return true;
  }

  void enterAsPlayer(String characterId) {
    selectedCharacterId = characterId;
    role = UserRole.player;
    unawaited(_rememberCharacter(characterId));
    notifyListeners();
  }

  void backToLanding() {
    role = UserRole.landing;
    notifyListeners();
  }

  void updateTable({required String name, String? code}) {
    final cleanedName = name.trim().isEmpty ? table.name : name.trim();
    final cleanedCode = code == null || code.trim().isEmpty
        ? table.code
        : code.trim().toUpperCase();
    table = table.copyWith(name: cleanedName, code: cleanedCode);
    unawaited(_rememberTable());
    _log('Mesa atualizada para ${table.name} (${table.code}).');
    notifyListeners();
  }

  void regenerateTableCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = (timestamp % 10000).toString().padLeft(4, '0');
    table = table.copyWith(code: 'GURI-$suffix');
    unawaited(_rememberTable());
    _log('Codigo da mesa regenerado: ${table.code}.');
    notifyListeners();
  }

  Future<void> openTableByCode(String rawCode) async {
    final code = TableCodeService.normalize(rawCode);
    if (code.isEmpty) return;

    final repository = _tableRepository;
    if (repository == null) {
      table = table.copyWith(code: code);
      await _rememberTable();
      notifyListeners();
      return;
    }

    final existing = await repository.findByCode(code);
    if (existing != null) {
      _switchTable(existing, seedCharacters: const []);
      await _rememberTable();
      _log('Mesa ${existing.code} carregada.');
      notifyListeners();
      return;
    }

    final newTable = RpgTable(
      id: TableCodeService.tableIdFromCode(code),
      name: 'RPG dos Guri',
      code: code,
    );
    _switchTable(newTable, seedCharacters: CharacterFactory.seedCharacters());
    await _rememberTable();
    _log('Mesa ${newTable.code} criada.');
    notifyListeners();
  }

  void _switchTable(
    RpgTable nextTable, {
    required List<CharacterSheet> seedCharacters,
  }) {
    _cancelFirestoreSubscriptions();
    _persistDebounce?.cancel();
    _remoteTableExists = false;
    _persistedTable = null;
    _persistedCombat = null;
    _persistedCharacters.clear();
    _applyingRemoteState = true;
    table = nextTable;
    characters = seedCharacters;
    pendingPlayerNames = nextTable.pendingPlayerNames;
    activeCombat = null;
    selectedCharacterId = null;
    actionLog.clear();
    _masterAuthorized =
        _preferences?.getBool('$_masterAuthPrefix${nextTable.id}') ?? false;
    role = UserRole.landing;
    _applyingRemoteState = false;
    _markCurrentStatePersisted();
    _connectFirestore();
  }

  void addCharacter(CharacterSheet character) {
    final prepared = _prepareCharacter(character);
    characters = [...characters, prepared];
    _log('Ficha de ${prepared.name} criada.');
    notifyListeners();
  }

  void requestPlayerApproval(String playerName) {
    final cleaned = playerName.trim();
    if (cleaned.isEmpty || pendingPlayerNames.contains(cleaned)) return;
    pendingPlayerNames = [...pendingPlayerNames, cleaned];
    table = table.copyWith(pendingPlayerNames: pendingPlayerNames);
    _log('$cleaned solicitou entrada na mesa.');
    notifyListeners();
  }

  void approvePlayer(String playerName) {
    pendingPlayerNames = pendingPlayerNames
        .where((name) => name != playerName)
        .toList();
    table = table.copyWith(pendingPlayerNames: pendingPlayerNames);
    characters = [
      ...characters,
      _prepareCharacter(CharacterFactory.blankForPlayer(playerName)),
    ];
    _log('$playerName foi aprovado pelo mestre.');
    notifyListeners();
  }

  void updateCharacter(
    CharacterSheet updated, {
    List<String> selectedMageSpellIds = const [],
  }) {
    final previous = characters
        .where((item) => item.id == updated.id)
        .firstOrNull;
    var prepared = _prepareCharacter(updated);
    if (previous != null) {
      prepared = prepared.copyWith(
        powers: CharacterPowerReconciliationService.reconcile(
          previous: previous,
          updated: prepared,
          races: races,
          progression: classProgression,
          spells: spellLibrary,
          selectedMageSpellIds: selectedMageSpellIds,
        ),
      );
      final validPowerIds = prepared.powers.map((power) => power.id).toSet();
      final validRequests = table.powerUseRequests
          .where(
            (request) =>
                request.characterId != prepared.id ||
                validPowerIds.contains(request.powerId),
          )
          .toList();
      if (validRequests.length != table.powerUseRequests.length) {
        table = table.copyWith(powerUseRequests: validRequests);
      }
    }
    characters = [
      for (final character in characters)
        if (character.id == prepared.id) prepared else character,
    ];
    _syncActiveParticipant(prepared);
    _log('Ficha de ${prepared.name} atualizada.');
    notifyListeners();
  }

  void upsertCharacterNote(String characterId, CampaignNote note) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(notes: _upsertNote(character.notes, note))
        else
          character,
    ];
    _log('Nota de ficha atualizada.');
    notifyListeners();
  }

  void deleteCharacterNote(String characterId, String noteId) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(
            notes: character.notes.where((note) => note.id != noteId).toList(),
          )
        else
          character,
    ];
    _log('Nota de ficha removida.');
    notifyListeners();
  }

  void upsertMasterNote(CampaignNote note) {
    table = table.copyWith(masterNotes: _upsertNote(table.masterNotes, note));
    _log('Nota do mestre atualizada.');
    notifyListeners();
  }

  void deleteMasterNote(String noteId) {
    table = table.copyWith(
      masterNotes: table.masterNotes
          .where((note) => note.id != noteId)
          .toList(),
    );
    _log('Nota do mestre removida.');
    notifyListeners();
  }

  void upsertStoryPoint(StoryPoint point) {
    final next = [
      for (final current in table.storyPoints)
        if (current.id == point.id) point else current,
    ];
    if (!next.any((current) => current.id == point.id)) next.add(point);
    next.sort((a, b) => a.order.compareTo(b.order));
    table = table.copyWith(storyPoints: next);
    _log('Ponto de história atualizado.');
    notifyListeners();
  }

  void deleteStoryPoint(String pointId) {
    table = table.copyWith(
      storyPoints: table.storyPoints
          .where((point) => point.id != pointId)
          .toList(),
    );
    _log('Ponto de história removido.');
    notifyListeners();
  }

  void moveStoryPoint(String pointId, int delta) {
    final points = [...table.storyPoints]
      ..sort((a, b) => a.order.compareTo(b.order));
    final index = points.indexWhere((point) => point.id == pointId);
    if (index < 0) return;
    final target = (index + delta).clamp(0, points.length - 1).toInt();
    if (target == index) return;
    final point = points.removeAt(index);
    points.insert(target, point);
    final now = DateTime.now();
    table = table.copyWith(
      storyPoints: [
        for (var index = 0; index < points.length; index += 1)
          points[index].copyWith(order: index, updatedAt: now),
      ],
    );
    _log('Ordem da história ajustada.');
    notifyListeners();
  }

  void reorderStoryPoint(String pointId, int newIndex) {
    final points = [...table.storyPoints]
      ..sort((a, b) => a.order.compareTo(b.order));
    final index = points.indexWhere((point) => point.id == pointId);
    if (index < 0) return;
    final target = newIndex.clamp(0, points.length - 1).toInt();
    if (target == index) return;
    final point = points.removeAt(index);
    points.insert(target, point);
    final now = DateTime.now();
    table = table.copyWith(
      storyPoints: [
        for (var index = 0; index < points.length; index += 1)
          points[index].copyWith(order: index, updatedAt: now),
      ],
    );
    _log('Ordem da história ajustada.');
    notifyListeners();
  }

  void upsertCustomNpc(CustomNpc npc) {
    final next = [
      for (final current in table.customNpcs)
        if (current.id == npc.id) npc else current,
    ];
    if (!next.any((current) => current.id == npc.id)) next.add(npc);
    next.sort((a, b) => a.name.compareTo(b.name));
    table = table.copyWith(customNpcs: next);
    _log(
      'NPC ${npc.name.trim().isEmpty ? 'customizado' : npc.name} atualizado.',
    );
    notifyListeners();
  }

  void deleteCustomNpc(String npcId) {
    table = table.copyWith(
      customNpcs: table.customNpcs.where((npc) => npc.id != npcId).toList(),
    );
    _log('NPC customizado removido.');
    notifyListeners();
  }

  void startCombat() {
    final participants = activeCharacters
        .map(CombatService.participantFromCharacter)
        .toList();
    activeCombat = CombatState(
      id: 'combat-${DateTime.now().millisecondsSinceEpoch}',
      active: true,
      round: 1,
      participants: participants,
    );
    table = table.copyWith(activeCombatId: activeCombat!.id);
    _log('Combate iniciado.');
    notifyListeners();
  }

  void addMissingPlayersToCombat() {
    final combat = activeCombat;
    if (combat == null) return;
    final existingCharacterIds = combat.participants
        .where((participant) => participant.type == ParticipantType.player)
        .map((participant) => participant.sourceCharacterId)
        .toSet();
    final missing = characters
        .where((character) => !character.archived)
        .where((character) => !existingCharacterIds.contains(character.id))
        .toList();
    if (missing.isEmpty) return;
    activeCombat = combat.copyWith(
      participants: [
        ...combat.participants,
        ...missing.map(CombatService.participantFromCharacter),
      ],
    );
    _log('${missing.length} jogador(es) adicionados ao combate.');
    notifyListeners();
  }

  void finishCombat() {
    final combatId = activeCombat?.id;
    resetCombatUses(emit: false);
    activeCombat = activeCombat?.copyWith(active: false);
    table = table.copyWith(activeCombatId: null);
    final combatRepository = _combatRepository;
    if (combatId != null && combatRepository != null) {
      unawaited(combatRepository.finishCombat(table.id, combatId));
    }
    _log('Combate finalizado. Usos por combate foram resetados.');
    notifyListeners();
  }

  void changeRound(int delta) {
    final combat = activeCombat;
    if (combat == null) return;
    activeCombat = combat.copyWith(
      round: (combat.round + delta).clamp(1, 999).toInt(),
    );
    _log('Rodada ajustada para ${activeCombat!.round}.');
    notifyListeners();
  }

  void addMonsterToCombat(
    MonsterTemplate template,
    int quantity, {
    int? maxHp,
    int? defense,
    String? damageSuggestion,
  }) {
    final combat = activeCombat;
    if (combat == null) return;

    final next = [...combat.participants];
    final hp = maxHp ?? template.maxHp;
    for (var index = 1; index <= quantity; index += 1) {
      next.add(
        CombatParticipant(
          id: 'monster-${DateTime.now().microsecondsSinceEpoch}-$index',
          name: quantity > 1 ? '${template.name} $index' : template.name,
          type: ParticipantType.monster,
          sourceMonsterId: template.id,
          currentHp: hp,
          maxHp: hp,
          defense: defense ?? template.defense,
          damageSuggestion: damageSuggestion?.trim().isEmpty == false
              ? damageSuggestion!.trim()
              : template.damage,
          statuses: const [],
        ),
      );
    }
    activeCombat = combat.copyWith(participants: next);
    _log('$quantity x ${template.name} adicionados ao combate.');
    notifyListeners();
  }

  void addCustomParticipant({
    required String name,
    required ParticipantType type,
    required int maxHp,
    required int defense,
    String? damageSuggestion,
  }) {
    final combat = activeCombat;
    if (combat == null) return;
    final hp = maxHp.clamp(1, 999).toInt();
    activeCombat = combat.copyWith(
      participants: [
        ...combat.participants,
        CombatParticipant(
          id: 'participant-${DateTime.now().microsecondsSinceEpoch}',
          name: name.trim().isEmpty ? 'Participante' : name.trim(),
          type: type,
          currentHp: hp,
          maxHp: hp,
          defense: defense.clamp(0, 99).toInt(),
          damageSuggestion: damageSuggestion?.trim(),
          statuses: const [],
        ),
      ],
    );
    _log(
      'Participante ${name.trim().isEmpty ? 'improvisado' : name.trim()} adicionado.',
    );
    notifyListeners();
  }

  void updateParticipant(CombatParticipant updated) {
    final combat = activeCombat;
    if (combat == null) return;
    activeCombat = combat.copyWith(
      participants: [
        for (final participant in combat.participants)
          if (participant.id == updated.id) updated else participant,
      ],
    );
    if (updated.sourceCharacterId case final characterId?) {
      characters = [
        for (final character in characters)
          if (character.id == characterId)
            character.copyWith(
              currentHp: updated.currentHp,
              statuses: updated.statuses,
            )
          else
            character,
      ];
    }
    _log('${updated.name} editado pelo mestre.');
    notifyListeners();
  }

  void setParticipantActiveWeaponSlot(
    String participantId,
    ActiveWeaponSlot slot,
  ) {
    _updateParticipant(
      participantId,
      (participant) => participant.copyWith(activeWeaponSlot: slot),
    );
    _log('Arma ativa do participante ajustada.');
  }

  void applyDamage(String participantId, int amount) {
    _updateParticipant(participantId, (participant) {
      final newHp = (participant.currentHp - amount)
          .clamp(0, participant.maxHp)
          .toInt();
      return participant.copyWith(
        currentHp: newHp,
        defeatedState: newHp == 0
            ? DefeatedState.unconscious
            : participant.defeatedState,
      );
    });
    _log('Dano final $amount aplicado.');
  }

  void applyHeal(String participantId, int amount) {
    _updateParticipant(participantId, (participant) {
      final newHp = (participant.currentHp + amount)
          .clamp(0, participant.maxHp)
          .toInt();
      return participant.copyWith(
        currentHp: newHp,
        defeatedState:
            newHp > 0 && participant.defeatedState == DefeatedState.unconscious
            ? DefeatedState.active
            : participant.defeatedState,
      );
    });
    _log('Cura final $amount aplicada.');
  }

  void addStatus(String participantId, StatusEntry status) {
    _updateParticipant(
      participantId,
      (participant) =>
          participant.copyWith(statuses: [...participant.statuses, status]),
    );
    _log('Status ${status.name} adicionado.');
  }

  void removeStatus(String participantId, String statusId) {
    _updateParticipant(
      participantId,
      (participant) => participant.copyWith(
        statuses: participant.statuses
            .where((status) => status.id != statusId)
            .toList(),
      ),
    );
    _log('Status removido.');
  }

  void setDefeatedState(String participantId, DefeatedState state) {
    _updateParticipant(
      participantId,
      (participant) => participant.copyWith(defeatedState: state),
    );
    _log('Estado manual alterado.');
  }

  void togglePowerUsed(String characterId, String powerId) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(
            powers: [
              for (final power in character.powers)
                power.id == powerId ? power.copyWith(used: !power.used) : power,
            ],
          )
        else
          character,
    ];
    _log('Uso de poder atualizado.');
    notifyListeners();
  }

  void requestPowerUse(String characterId, String powerId) {
    final character = characters
        .where((item) => item.id == characterId && !item.archived)
        .firstOrNull;
    final power = character?.powers
        .where((item) => item.id == powerId)
        .firstOrNull;
    if (character == null || power == null || power.used) return;
    final alreadyRequested = table.powerUseRequests.any(
      (request) =>
          request.characterId == characterId && request.powerId == powerId,
    );
    if (alreadyRequested) return;
    final request = PowerUseRequest(
      id: 'power-request-${DateTime.now().microsecondsSinceEpoch}',
      characterId: character.id,
      characterName: character.name,
      powerId: power.id,
      powerName: power.name,
      usageLimit: power.usageLimit,
      createdAt: DateTime.now(),
    );
    table = table.copyWith(
      powerUseRequests: [...table.powerUseRequests, request],
    );
    _log('${character.name} pediu uso de ${power.name}.');
    notifyListeners();
  }

  void approvePowerUse(String requestId) {
    final request = table.powerUseRequests
        .where((item) => item.id == requestId)
        .firstOrNull;
    if (request == null) return;
    characters = [
      for (final character in characters)
        if (character.id == request.characterId)
          character.copyWith(
            powers: [
              for (final power in character.powers)
                power.id == request.powerId
                    ? power.copyWith(used: true)
                    : power,
            ],
          )
        else
          character,
    ];
    table = table.copyWith(
      powerUseRequests: table.powerUseRequests
          .where((item) => item.id != requestId)
          .toList(),
    );
    _log('${request.powerName} de ${request.characterName} aprovado.');
    notifyListeners();
  }

  void discardPowerUseRequest(String requestId) {
    final request = table.powerUseRequests
        .where((item) => item.id == requestId)
        .firstOrNull;
    table = table.copyWith(
      powerUseRequests: table.powerUseRequests
          .where((item) => item.id != requestId)
          .toList(),
    );
    if (request != null) {
      _log('Pedido de ${request.powerName} descartado.');
    }
    notifyListeners();
  }

  void resetCombatUses({bool emit = true}) {
    characters = [
      for (final character in characters)
        character.copyWith(
          powers: [
            for (final power in character.powers)
              power.usageLimit == UsageLimit.combat
                  ? power.copyWith(used: false)
                  : power,
          ],
        ),
    ];
    if (emit) {
      _log('Usos por combate resetados.');
      notifyListeners();
    }
  }

  void resetSessionUses() {
    _resetUsesFor(UsageLimit.session, 'Usos por sessao resetados.');
  }

  void resetLongRestUses() {
    _resetUsesFor(UsageLimit.longRest, 'Usos por descanso longo resetados.');
  }

  void _resetUsesFor(UsageLimit usageLimit, String message) {
    characters = [
      for (final character in characters)
        character.copyWith(
          powers: [
            for (final power in character.powers)
              power.usageLimit == usageLimit
                  ? power.copyWith(used: false)
                  : power,
          ],
        ),
    ];
    _log(message);
    notifyListeners();
  }

  void archiveCharacter(String characterId) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(archived: true)
        else
          character,
    ];
    if (selectedCharacterId == characterId) selectedCharacterId = null;
    table = table.copyWith(
      powerUseRequests: table.powerUseRequests
          .where((request) => request.characterId != characterId)
          .toList(),
    );
    _log('Ficha arquivada.');
    notifyListeners();
  }

  void restoreCharacter(String characterId) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(archived: false)
        else
          character,
    ];
    _log('Ficha restaurada.');
    notifyListeners();
  }

  void addPowerToCharacter(String characterId, PowerTemplate template) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(powers: [...character.powers, template.toEntry()])
        else
          character,
    ];
    _log('${template.name} adicionado a ficha.');
    notifyListeners();
  }

  void addSpellToCharacter(String characterId, SpellTemplate template) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(powers: [...character.powers, template.toEntry()])
        else
          character,
    ];
    _log('${template.name} adicionado a ficha.');
    notifyListeners();
  }

  void addRitualToCharacter(String characterId, RitualTemplate template) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(
            powers: [
              ...character.powers,
              PowerEntry(
                id: '${template.id}-${DateTime.now().microsecondsSinceEpoch}',
                name: template.name,
                type: 'Ritual',
                description: template.description,
                suggestedTest: template.suggestedRoll,
                effect: template.effect ?? template.difficulty,
                usageLimit: UsageLimit.free,
                origin: template.origin ?? 'Ritual',
                actionCost: template.actionCost,
                range: template.range,
                duration: template.duration,
                roll: template.suggestedRoll,
                extraEffect: template.extraEffect,
                notes: template.notes,
                source: template.source,
              ),
            ],
          )
        else
          character,
    ];
    _log('${template.name} adicionado a ficha.');
    notifyListeners();
  }

  void addItemToCharacter(
    String characterId,
    ItemTemplate template, {
    int? quantity,
  }) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(
            inventory: [
              ...character.inventory,
              template.toItem(quantity: quantity),
            ],
          )
        else
          character,
    ];
    _log('${template.name} adicionado ao inventario.');
    notifyListeners();
  }

  void upsertInventoryItem(String characterId, InventoryItem item) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(
            inventory:
                character.inventory.any((current) => current.id == item.id)
                ? [
                    for (final current in character.inventory)
                      if (current.id == item.id) item else current,
                  ]
                : [...character.inventory, item],
          )
        else
          character,
    ];
    _log('${item.name} atualizado no inventario.');
    notifyListeners();
  }

  void removeInventoryItem(String characterId, String itemId) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          character.copyWith(
            inventory: character.inventory
                .where((item) => item.id != itemId)
                .toList(),
          )
        else
          character,
    ];
    _log('Item removido do inventario.');
    notifyListeners();
  }

  void applyConsumable({
    required String characterId,
    required String itemId,
    required String targetParticipantId,
    required int rolledValue,
  }) {
    CharacterSheet? character;
    InventoryItem? item;
    for (final current in characters) {
      if (current.id == characterId) {
        character = current;
        for (final inventoryItem in current.inventory) {
          if (inventoryItem.id == itemId) item = inventoryItem;
        }
      }
    }
    if (character == null || item == null || item.quantity <= 0) return;
    final actingCharacter = character;
    final usedItem = item;

    final total = rolledValue + usedItem.fixedBonus;
    if (usedItem.effectKind == 'heal') {
      applyHeal(targetParticipantId, total);
    } else if (usedItem.effectKind == 'damage') {
      applyDamage(targetParticipantId, total);
    }

    characters = [
      for (final current in characters)
        if (current.id == characterId)
          current.copyWith(
            inventory: [
              for (final inventoryItem in current.inventory)
                if (inventoryItem.id == itemId)
                  inventoryItem.copyWith(
                    quantity: (inventoryItem.quantity - 1)
                        .clamp(0, 999)
                        .toInt(),
                  )
                else
                  inventoryItem,
            ],
          )
        else
          current,
    ];
    _log(
      '${actingCharacter.name} usou ${usedItem.name}. Total aplicado: $total.',
    );
    notifyListeners();
  }

  void levelUp(String characterId, {String? selectedSpellId}) {
    characters = [
      for (final character in characters)
        if (character.id == characterId)
          _leveledCharacter(character, selectedSpellId: selectedSpellId)
        else
          character,
    ];
    _log('Nivel aumentado pelo mestre.');
    notifyListeners();
  }

  CharacterSheet _leveledCharacter(
    CharacterSheet character, {
    String? selectedSpellId,
  }) {
    if (character.level >= 10) return character;
    final newLevel = character.level + 1;
    final additions = <PowerEntry>[];

    final progression = CharacterProgressionService.progressionFor(
      progression: classProgression,
      characterClass: character.characterClass,
      level: newLevel,
    );
    if (progression != null && !_hasPowerNamed(character, progression.name)) {
      additions.add(progression.toPowerEntry());
    }

    if (OfficialNameMatcher.same(character.characterClass, 'Mago')) {
      final selectedSpell = OfficialNameMatcher.firstWhereOrNull(
        spellLibrary,
        (spell) => spell.id == selectedSpellId,
      );
      if (selectedSpell != null &&
          !_hasPowerNamed(character, selectedSpell.name)) {
        additions.add(selectedSpell.toEntry());
      }
    }

    return character.copyWith(
      level: newLevel,
      powers: [...character.powers, ...additions],
    );
  }

  CharacterSheet _prepareCharacter(CharacterSheet character) {
    final normalizedRace = _officialRaceName(character.race);
    final normalizedClass = _officialClassName(character.characterClass);
    final normalizedArmor = _officialEquipmentName(
      character.armor,
      EquipmentCategory.armor,
      fallback: 'Sem armadura',
    );
    final normalizedMainWeapon = _officialEquipmentName(
      character.mainWeapon,
      EquipmentCategory.weapon,
      fallback: weapons.isNotEmpty ? weapons.first.name : character.mainWeapon,
    );
    final secondaryCategory = _isShieldName(character.secondaryItem)
        ? EquipmentCategory.shield
        : EquipmentCategory.weapon;
    final normalizedSecondary = _officialEquipmentName(
      character.secondaryItem,
      secondaryCategory,
      fallback: secondaryCategory == EquipmentCategory.shield
          ? (shields.isNotEmpty ? shields.first.name : character.secondaryItem)
          : (weapons.isNotEmpty ? weapons.first.name : character.secondaryItem),
    );
    final normalizedAccessories = character.accessories
        .map(
          (name) => _officialEquipmentName(
            name,
            EquipmentCategory.accessory,
            fallback: '',
          ),
        )
        .where((name) => name.isNotEmpty)
        .take(2)
        .toList();
    final powers = character.powers.isEmpty
        ? _defaultPowers(normalizedRace, normalizedClass)
        : _ensureOfficialInitialPowers(
            character.copyWith(
              race: normalizedRace,
              characterClass: normalizedClass,
            ),
          );
    final inventory = character.inventory.isEmpty
        ? _starterItemsForClass(normalizedClass)
        : character.inventory;

    return character.copyWith(
      race: normalizedRace,
      characterClass: normalizedClass,
      armor: normalizedArmor,
      hasShield: _isShieldName(normalizedSecondary),
      mainWeapon: normalizedMainWeapon,
      secondaryItem: normalizedSecondary,
      accessories: normalizedAccessories,
      powers: powers,
      inventory: inventory,
    );
  }

  List<PowerEntry> _ensureOfficialInitialPowers(CharacterSheet character) {
    final powers = [...character.powers];
    for (final power in _defaultPowers(
      character.race,
      character.characterClass,
    )) {
      if (!powers.any(
        (current) => OfficialNameMatcher.same(current.name, power.name),
      )) {
        powers.add(power);
      }
    }
    return powers;
  }

  List<PowerEntry> _defaultPowers(String race, String characterClass) {
    final entries = <PowerEntry>[];
    final raceTemplate = OfficialNameMatcher.firstWhereOrNull(
      races,
      (item) => OfficialNameMatcher.same(item.name, race),
    );
    if (raceTemplate != null) entries.add(raceTemplate.toPowerEntry());

    final initialPower = OfficialNameMatcher.firstWhereOrNull(
      classProgression,
      (entry) =>
          OfficialNameMatcher.same(entry.characterClass, characterClass) &&
          entry.level == 1,
    );
    if (initialPower != null) entries.add(initialPower.toPowerEntry());

    if (OfficialNameMatcher.same(characterClass, 'Mago')) {
      entries.addAll([
        ...spellLibrary
            .where(
              (spell) =>
                  spell.tier == 'Magia simples' &&
                  const {
                    'bola-de-fogo-pequena',
                    'raio-arcano',
                    'luz-magica',
                  }.contains(spell.id),
            )
            .map((spell) => spell.toEntry()),
        if (spellLibrary.any((spell) => spell.usageLimit == UsageLimit.combat))
          spellLibrary
              .firstWhere((spell) => spell.usageLimit == UsageLimit.combat)
              .toEntry(),
      ]);
    }

    return entries;
  }

  List<InventoryItem> _starterItemsForClass(String characterClass) {
    final preferredNames = switch (OfficialNameMatcher.canonical(
      characterClass,
    )) {
      'guerreiro' => ['Pocao de Cura', 'Kit de Curativo', 'Corda'],
      'ladino' => ['Pocao de Cura', 'Bomba de Fumaca', 'Corda'],
      'mago' => ['Pocao de Cura', 'Pergaminho de Luz', 'Tocha'],
      'clerigo' => ['Pocao de Cura', 'Kit de Curativo', 'Agua Benta'],
      _ => ['Pocao de Cura', 'Tocha', 'Corda'],
    };
    return [
      for (final name in preferredNames)
        if (_templateByName(name) case final template?) template.toItem(),
    ];
  }

  ItemTemplate? _templateByName(String name) {
    return OfficialNameMatcher.firstWhereOrNull(
      itemLibrary,
      (item) => OfficialNameMatcher.same(item.name, name),
    );
  }

  String _officialRaceName(String name) {
    return OfficialNameMatcher.firstWhereOrNull(
          races,
          (item) => OfficialNameMatcher.same(item.name, name),
        )?.name ??
        (races.isNotEmpty ? races.first.name : name);
  }

  String _officialClassName(String name) {
    return OfficialNameMatcher.firstWhereOrNull(
          classes,
          (item) => OfficialNameMatcher.same(item.name, name),
        )?.name ??
        (classes.isNotEmpty ? classes.first.name : name);
  }

  String _officialEquipmentName(
    String name,
    EquipmentCategory category, {
    required String fallback,
  }) {
    return OfficialNameMatcher.firstWhereOrNull(
          equipmentLibrary,
          (item) =>
              item.category == category &&
              OfficialNameMatcher.same(item.name, name),
        )?.name ??
        fallback;
  }

  bool _isShieldName(String name) {
    return shields.any((item) => OfficialNameMatcher.same(item.name, name));
  }

  List<CampaignNote> _upsertNote(List<CampaignNote> notes, CampaignNote note) {
    final next = [
      for (final current in notes)
        if (current.id == note.id) note else current,
    ];
    if (!next.any((current) => current.id == note.id)) next.add(note);
    next.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return next;
  }

  void _indexEquipment() {
    _equipmentByName = {
      for (final item in equipmentLibrary)
        OfficialNameMatcher.canonical(item.name): item,
    };
    _equipmentByCategory = {
      for (final category in EquipmentCategory.values)
        category: [
          for (final item in equipmentLibrary)
            if (item.category == category) item,
        ],
    };
  }

  bool _hasPowerNamed(CharacterSheet character, String name) {
    return character.powers.any(
      (power) => OfficialNameMatcher.same(power.name, name),
    );
  }

  void _updateParticipant(
    String participantId,
    CombatParticipant Function(CombatParticipant) update,
  ) {
    final combat = activeCombat;
    if (combat == null) return;

    CombatParticipant? changed;
    final participants = [
      for (final participant in combat.participants)
        if (participant.id == participantId)
          changed = update(participant)
        else
          participant,
    ];

    activeCombat = combat.copyWith(participants: participants);
    final changedParticipant = changed;
    final characterId = changedParticipant?.sourceCharacterId;
    if (changedParticipant != null && characterId != null) {
      characters = [
        for (final character in characters)
          if (character.id == characterId)
            character.copyWith(
              currentHp: changedParticipant.currentHp,
              statuses: changedParticipant.statuses,
            )
          else
            character,
      ];
    }
    notifyListeners();
  }

  void _syncActiveParticipant(CharacterSheet updated) {
    final combat = activeCombat;
    if (combat == null) return;
    activeCombat = combat.copyWith(
      participants: [
        for (final participant in combat.participants)
          if (participant.sourceCharacterId == updated.id)
            participant.copyWith(
              maxHp: updated.maxHp,
              defense: updated.defense,
              statuses: updated.statuses,
            )
          else
            participant,
      ],
    );
  }

  void _log(String message) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final entry = '$time - $message';
    actionLog.insert(0, entry);
    if (actionLog.length > 30) actionLog.removeLast();
    if (!_applyingRemoteState) {
      final repository = _actionLogRepository;
      if (repository != null) unawaited(repository.add(table.id, entry));
    }
  }

  String _masterPinHash(String pin, String tableId) {
    return sha256.convert(utf8.encode('$tableId:$pin')).toString();
  }

  Future<void> _rememberTable() async {
    await _preferences?.setString(_lastTableCodeKey, table.code);
  }

  Future<void> _rememberCharacter(String characterId) async {
    await _preferences?.setString(_lastCharacterIdKey, characterId);
  }

  Future<void> _rememberMasterAuth() async {
    await _preferences?.setBool('$_masterAuthPrefix${table.id}', true);
  }
}
