import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/official_library_repository.dart';
import '../data/rpg_repositories.dart';
import '../models/rpg_models.dart';

class RpgSessionController extends ChangeNotifier {
  RpgSessionController.seeded()
    : table = const RpgTable(
        id: 'mesa-rpg-dos-guri',
        name: 'RPG dos Guri',
        code: 'GURI-1234',
      ),
      characters = _seedCharacters(),
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
       characters = _seedCharacters(),
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
  List<String> pendingPlayerNames = [];
  final List<String> actionLog = [];
  StreamSubscription<RpgTable?>? _tableSubscription;
  StreamSubscription<List<CharacterSheet>>? _characterSubscription;
  StreamSubscription<CombatState?>? _combatSubscription;
  StreamSubscription<List<String>>? _logSubscription;
  Timer? _persistDebounce;
  bool _applyingRemoteState = false;
  bool _remoteTableExists = false;

  List<EquipmentTemplate> get weapons => equipmentLibrary
      .where((item) => item.category == EquipmentCategory.weapon)
      .toList();

  List<EquipmentTemplate> get shields => equipmentLibrary
      .where((item) => item.category == EquipmentCategory.shield)
      .toList();

  List<EquipmentTemplate> get armors => equipmentLibrary
      .where((item) => item.category == EquipmentCategory.armor)
      .toList();

  List<EquipmentTemplate> get accessories => equipmentLibrary
      .where((item) => item.category == EquipmentCategory.accessory)
      .toList();

  EquipmentTemplate? equipmentByName(String name) {
    return _firstWhereOrNull(
      equipmentLibrary,
      (item) => _sameOfficialName(item.name, name),
    );
  }

  CharacterSheet? get selectedCharacter {
    if (selectedCharacterId == null) return null;
    for (final character in characters) {
      if (character.id == selectedCharacterId) return character;
    }
    return null;
  }

  Future<void> _loadOfficialLibrary() async {
    try {
      final library = await _libraryRepository.load();
      races = library.races;
      classes = library.classes;
      monsters = library.monsters;
      powerLibrary = library.powers;
      spellLibrary = library.spells;
      ritualLibrary = library.rituals;
      itemLibrary = library.items;
      equipmentLibrary = library.equipment;
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
    if (!_applyingRemoteState) _schedulePersistSnapshot();
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
        _persistSnapshot();
        return;
      }
      _remoteTableExists = true;
      _applyRemoteState(() {
        table = remoteTable;
        pendingPlayerNames = remoteTable.pendingPlayerNames;
      });
    });

    _characterSubscription = _characterRepository
        ?.watchCharacters(table.id)
        .listen((remoteCharacters) {
          if (!_remoteTableExists && remoteCharacters.isEmpty) {
            return;
          }
          _applyRemoteState(() => characters = remoteCharacters);
        });

    _combatSubscription = _combatRepository?.watchActiveCombat(table.id).listen(
      (remoteCombat) {
        _applyRemoteState(() {
          activeCombat = remoteCombat;
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
    _applyingRemoteState = true;
    apply();
    super.notifyListeners();
    _applyingRemoteState = false;
  }

  void _schedulePersistSnapshot() {
    if (_tableRepository == null ||
        _characterRepository == null ||
        _combatRepository == null) {
      return;
    }
    _persistDebounce?.cancel();
    _persistDebounce = Timer(
      const Duration(milliseconds: 250),
      _persistSnapshot,
    );
  }

  Future<void> _persistSnapshot() async {
    if (_applyingRemoteState) return;
    final tableRepository = _tableRepository;
    final characterRepository = _characterRepository;
    final combatRepository = _combatRepository;
    if (tableRepository == null ||
        characterRepository == null ||
        combatRepository == null) {
      return;
    }

    try {
      table = table.copyWith(pendingPlayerNames: pendingPlayerNames);
      await tableRepository.saveTable(table);
      await Future.wait([
        for (final character in characters)
          characterRepository.saveCharacter(table.id, character),
      ]);
      final combat = activeCombat;
      if (combat != null) {
        await combatRepository.saveCombat(table.id, combat);
      }
    } catch (error, stackTrace) {
      debugPrint('Falha ao sincronizar Firestore: $error');
      debugPrint('$stackTrace');
    }
  }

  void enterAsMaster() {
    role = UserRole.master;
    notifyListeners();
  }

  void enterAsPlayer(String characterId) {
    selectedCharacterId = characterId;
    role = UserRole.player;
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
    _log('Mesa atualizada para ${table.name} (${table.code}).');
    notifyListeners();
  }

  void regenerateTableCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = (timestamp % 10000).toString().padLeft(4, '0');
    table = table.copyWith(code: 'GURI-$suffix');
    _log('Codigo da mesa regenerado: ${table.code}.');
    notifyListeners();
  }

  Future<void> openTableByCode(String rawCode) async {
    final code = _normalizeTableCode(rawCode);
    if (code.isEmpty) return;

    final repository = _tableRepository;
    if (repository == null) {
      table = table.copyWith(code: code);
      notifyListeners();
      return;
    }

    final existing = await repository.findByCode(code);
    if (existing != null) {
      _switchTable(existing, seedCharacters: const []);
      _log('Mesa ${existing.code} carregada.');
      notifyListeners();
      return;
    }

    final newTable = RpgTable(
      id: _tableIdFromCode(code),
      name: 'RPG dos Guri',
      code: code,
    );
    _switchTable(newTable, seedCharacters: _seedCharacters());
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
    _applyingRemoteState = true;
    table = nextTable;
    characters = seedCharacters;
    pendingPlayerNames = nextTable.pendingPlayerNames;
    activeCombat = null;
    selectedCharacterId = null;
    actionLog.clear();
    role = UserRole.landing;
    _applyingRemoteState = false;
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
      _prepareCharacter(_blankCharacterForPlayer(playerName)),
    ];
    _log('$playerName foi aprovado pelo mestre.');
    notifyListeners();
  }

  void updateCharacter(CharacterSheet updated) {
    final prepared = _prepareCharacter(updated);
    characters = [
      for (final character in characters)
        if (character.id == prepared.id) prepared else character,
    ];
    _syncActiveParticipant(prepared);
    _log('Ficha de ${prepared.name} atualizada.');
    notifyListeners();
  }

  void startCombat() {
    final participants = characters.map(_participantFromCharacter).toList();
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
        .where((character) => !existingCharacterIds.contains(character.id))
        .toList();
    if (missing.isEmpty) return;
    activeCombat = combat.copyWith(
      participants: [
        ...combat.participants,
        ...missing.map(_participantFromCharacter),
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

  void togglePowerRequest(String characterId, String powerId) {
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
    _log('Solicitacao/uso de poder registrado.');
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
                effect: template.difficulty,
                usageLimit: UsageLimit.free,
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

    final progression = _firstWhereOrNull(
      classProgression,
      (entry) =>
          _sameOfficialName(entry.characterClass, character.characterClass) &&
          entry.level == newLevel,
    );
    if (progression != null && !_hasPowerNamed(character, progression.name)) {
      additions.add(progression.toPowerEntry());
    }

    if (_sameOfficialName(character.characterClass, 'Mago')) {
      final selectedSpell = _firstWhereOrNull(
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
        (current) => _sameOfficialName(current.name, power.name),
      )) {
        powers.add(power);
      }
    }
    return powers;
  }

  List<PowerEntry> _defaultPowers(String race, String characterClass) {
    final entries = <PowerEntry>[];
    final raceTemplate = _firstWhereOrNull(
      races,
      (item) => _sameOfficialName(item.name, race),
    );
    if (raceTemplate != null) entries.add(raceTemplate.toPowerEntry());

    final initialPower = _firstWhereOrNull(
      classProgression,
      (entry) =>
          _sameOfficialName(entry.characterClass, characterClass) &&
          entry.level == 1,
    );
    if (initialPower != null) entries.add(initialPower.toPowerEntry());

    if (_sameOfficialName(characterClass, 'Mago')) {
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
    final preferredNames = switch (_canonicalName(characterClass)) {
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
    return _firstWhereOrNull(
      itemLibrary,
      (item) => _sameOfficialName(item.name, name),
    );
  }

  String _officialRaceName(String name) {
    return _firstWhereOrNull(
          races,
          (item) => _sameOfficialName(item.name, name),
        )?.name ??
        (races.isNotEmpty ? races.first.name : name);
  }

  String _officialClassName(String name) {
    return _firstWhereOrNull(
          classes,
          (item) => _sameOfficialName(item.name, name),
        )?.name ??
        (classes.isNotEmpty ? classes.first.name : name);
  }

  String _officialEquipmentName(
    String name,
    EquipmentCategory category, {
    required String fallback,
  }) {
    return _firstWhereOrNull(
          equipmentLibrary,
          (item) =>
              item.category == category && _sameOfficialName(item.name, name),
        )?.name ??
        fallback;
  }

  bool _isShieldName(String name) {
    return shields.any((item) => _sameOfficialName(item.name, name));
  }

  bool _hasPowerNamed(CharacterSheet character, String name) {
    return character.powers.any((power) => _sameOfficialName(power.name, name));
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
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}

bool _sameOfficialName(String left, String right) {
  return _canonicalName(left) == _canonicalName(right);
}

String _canonicalName(String value) {
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

String _normalizeTableCode(String rawCode) {
  final cleaned = rawCode.trim().toUpperCase().replaceAll(' ', '-');
  if (cleaned.isEmpty) return '';
  if (cleaned.startsWith('GURI-')) return cleaned;
  return 'GURI-$cleaned';
}

String _tableIdFromCode(String code) {
  final slug = code.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
  return 'table-${slug.replaceAll(RegExp('-+'), '-').replaceAll(RegExp(r'(^-|-$)'), '')}';
}

CombatParticipant _participantFromCharacter(CharacterSheet character) {
  return CombatParticipant(
    id: 'participant-${character.id}',
    sourceCharacterId: character.id,
    name: character.name,
    type: ParticipantType.player,
    currentHp: character.currentHp,
    maxHp: character.maxHp,
    defense: character.defense,
    statuses: character.statuses,
    damageSuggestion: 'Mestre informa dano final',
  );
}

List<CharacterSheet> _seedCharacters() {
  return [
    CharacterSheet(
      id: 'borin',
      name: 'Borin',
      race: 'Anao',
      characterClass: 'Guerreiro',
      level: 1,
      concept: 'Defensor teimoso da companhia',
      attributes: const {
        'Forca': 3,
        'Agilidade': 0,
        'Intelecto': 0,
        'Presenca': 1,
        'Vigor': 4,
      },
      skills: const {
        'Atletismo': 2,
        'Furtividade': 0,
        'Percepcao': 1,
        'Natureza': 0,
        'Conhecimento': 0,
        'Influencia': 0,
        'Oficio': 1,
        'Combate': 2,
        'Misticismo': 0,
      },
      currentHp: 14,
      armor: 'Armadura pesada',
      hasShield: true,
      mainWeapon: 'Espada longa',
      secondaryItem: 'Escudo',
      accessories: const [],
      powers: const [],
      inventory: const [],
      statuses: const [],
      coins: 5,
    ),
    CharacterSheet(
      id: 'lyra',
      name: 'Lyra',
      race: 'Elfo',
      characterClass: 'Mago',
      level: 1,
      concept: 'Estudiosa arcana curiosa',
      attributes: const {
        'Forca': -1,
        'Agilidade': 2,
        'Intelecto': 4,
        'Presenca': 1,
        'Vigor': 1,
      },
      skills: const {
        'Atletismo': 0,
        'Furtividade': 1,
        'Percepcao': 2,
        'Natureza': 1,
        'Conhecimento': 2,
        'Influencia': 0,
        'Oficio': 0,
        'Combate': 0,
        'Misticismo': 3,
      },
      currentHp: 11,
      armor: 'Sem armadura',
      hasShield: false,
      mainWeapon: 'Cajado',
      secondaryItem: 'Bolsa de componentes',
      accessories: const [],
      powers: const [],
      inventory: const [],
      statuses: const [],
      coins: 5,
    ),
  ];
}

CharacterSheet _blankCharacterForPlayer(String playerName) {
  return CharacterSheet(
    id: 'char-${DateTime.now().microsecondsSinceEpoch}',
    name: playerName,
    race: 'Humano',
    characterClass: 'Guerreiro',
    level: 1,
    concept: 'Conceito a definir',
    attributes: const {
      'Forca': 0,
      'Agilidade': 0,
      'Intelecto': 0,
      'Presenca': 0,
      'Vigor': 0,
    },
    skills: const {
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
    currentHp: 10,
    armor: 'Sem armadura',
    hasShield: false,
    mainWeapon: 'Arma simples',
    secondaryItem: 'Item secundario',
    accessories: const [],
    powers: const [],
    inventory: const [],
    statuses: const [],
    coins: 5,
    ownerName: playerName,
  );
}
