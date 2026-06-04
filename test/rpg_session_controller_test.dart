import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rpg_dos_guri/features/rpg/application/application.dart';
import 'package:rpg_dos_guri/features/rpg/domain/domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PIN correto libera mestre e PIN errado nao libera', () async {
    final controller = RpgSessionController.seeded();

    expect(await controller.enterAsMasterWithPin('1234'), isTrue);
    controller.backToLanding();

    expect(await controller.enterAsMasterWithPin('0000'), isFalse);
    expect(controller.role, UserRole.landing);
    expect(await controller.enterAsMasterWithPin('1234'), isTrue);
    expect(controller.role, UserRole.master);
  });

  test('pedido de poder entra na fila e aprovacao marca como usado', () {
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'power-1',
          name: 'Golpe Teste',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.session,
        ),
      ],
    );
    controller.updateCharacter(character);

    controller.requestPowerUse(character.id, 'power-1');
    expect(controller.powerUseRequests, hasLength(1));

    controller.approvePowerUse(controller.powerUseRequests.first.id);
    expect(controller.powerUseRequests, isEmpty);
    expect(controller.characters.first.powers.first.used, isTrue);
  });

  test('descartar pedido nao marca poder como usado', () {
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'power-1',
          name: 'Golpe Teste',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.session,
        ),
      ],
    );
    controller.updateCharacter(character);

    controller.requestPowerUse(character.id, 'power-1');
    controller.discardPowerUseRequest(controller.powerUseRequests.first.id);

    expect(controller.powerUseRequests, isEmpty);
    expect(controller.characters.first.powers.first.used, isFalse);
  });

  test('arquivar remove ficha das listas ativas e restaurar volta', () {
    final controller = RpgSessionController.seeded();
    final characterId = controller.characters.first.id;

    controller.archiveCharacter(characterId);
    expect(
      controller.activeCharacters.any(
        (character) => character.id == characterId,
      ),
      isFalse,
    );
    expect(
      controller.archivedCharacters.any(
        (character) => character.id == characterId,
      ),
      isTrue,
    );

    controller.restoreCharacter(characterId);
    expect(
      controller.activeCharacters.any(
        (character) => character.id == characterId,
      ),
      isTrue,
    );
  });

  test('resets afetam apenas os limites corretos', () {
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'combat',
          name: 'Combate',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.combat,
          used: true,
        ),
        PowerEntry(
          id: 'session',
          name: 'Sessao',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.session,
          used: true,
        ),
        PowerEntry(
          id: 'rest',
          name: 'Descanso',
          type: 'Habilidade',
          description: 'Teste',
          suggestedTest: 'Combate',
          effect: 'Dano',
          usageLimit: UsageLimit.longRest,
          used: true,
        ),
      ],
    );
    controller.updateCharacter(character);

    controller.resetCombatUses();
    expect(controller.characters.first.powers[0].used, isFalse);
    expect(controller.characters.first.powers[1].used, isTrue);
    expect(controller.characters.first.powers[2].used, isTrue);

    controller.resetSessionUses();
    expect(controller.characters.first.powers[1].used, isFalse);
    expect(controller.characters.first.powers[2].used, isTrue);

    controller.resetLongRestUses();
    expect(controller.characters.first.powers[2].used, isFalse);
  });

  test('query de mesa vence cache local', () async {
    SharedPreferences.setMockInitialValues({'rpg.lastTableCode': 'GURI-1111'});
    final controller = RpgSessionController.seeded();

    await controller.bootstrap(initialTableCode: 'GURI-2222');

    expect(controller.table.code, 'GURI-2222');
  });

  test('troca de classe remove pedidos de poderes descartados', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final character = controller.characters.first.copyWith(
      powers: const [
        PowerEntry(
          id: 'classe-antiga',
          name: 'Golpe antigo',
          type: 'Habilidade de classe',
          description: '',
          suggestedTest: '',
          effect: '',
          usageLimit: UsageLimit.combat,
        ),
      ],
    );
    controller.updateCharacter(character);
    controller.requestPowerUse(character.id, 'classe-antiga');

    controller.updateCharacter(character.copyWith(characterClass: 'Ladino'));

    expect(controller.powerUseRequests, isEmpty);
  });

  test('edicao de ficha preserva acessorios vazios', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final character = controller.characters.first.copyWith(
      accessories: const [],
    );

    controller.updateCharacter(character);

    expect(controller.characters.first.accessories, isEmpty);
  });

  test('notas historia npcs e mencoes sao atualizados na mesa', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final now = DateTime(2026, 6, 4, 12);
    final masterNote = CampaignNote(
      id: 'note-1',
      createdAt: now,
      updatedAt: now,
      title: 'Cena',
      body: '@${controller.characters.first.name} encontrou @Bardo',
    );
    final storyPoint = StoryPoint(
      id: 'story-1',
      createdAt: now,
      updatedAt: now,
      title: 'Gancho',
      body: 'Encontrar @Bardo',
      order: 0,
    );
    final npc = CustomNpc(
      id: 'npc-1',
      createdAt: now,
      updatedAt: now,
      name: 'Bardo',
      occupation: 'Informante',
    );

    controller.upsertMasterNote(masterNote);
    controller.upsertStoryPoint(storyPoint);
    controller.upsertCustomNpc(npc);

    expect(controller.table.masterNotes.single.title, 'Cena');
    expect(controller.table.storyPoints.single.title, 'Gancho');
    expect(controller.table.customNpcs.single.name, 'Bardo');
    expect(
      controller.mentionTargetByName(controller.characters.first.name),
      isA<CharacterSheet>(),
    );
    expect(controller.mentionTargetByName('Bardo'), isA<CustomNpc>());
  });

  test('mencao duplicada prioriza jogador ativo antes de npc', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final now = DateTime(2026, 6, 4, 12);
    controller.upsertCustomNpc(
      CustomNpc(
        id: 'npc-1',
        createdAt: now,
        updatedAt: now,
        name: controller.characters.first.name,
      ),
    );

    expect(
      controller.mentionTargetByName(controller.characters.first.name),
      isA<CharacterSheet>(),
    );
  });

  test('sugestoes de mencao retornam jogadores antes de npcs', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final now = DateTime(2026, 6, 4, 12);
    final playerName = controller.characters.first.name;
    controller.upsertCustomNpc(
      CustomNpc(id: 'npc-1', createdAt: now, updatedAt: now, name: playerName),
    );

    final suggestions = controller.mentionSuggestions(playerName);

    expect(suggestions.first, isA<CharacterSheet>());
    expect(suggestions.whereType<CustomNpc>(), isNotEmpty);
  });

  test('reordenacao de historia por indice persiste nova ordem', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final now = DateTime(2026, 6, 4, 12);
    controller.upsertStoryPoint(
      StoryPoint(
        id: 'story-1',
        createdAt: now,
        updatedAt: now,
        title: 'Primeira',
        body: '',
        order: 0,
      ),
    );
    controller.upsertStoryPoint(
      StoryPoint(
        id: 'story-2',
        createdAt: now,
        updatedAt: now,
        title: 'Segunda',
        body: '',
        order: 1,
      ),
    );

    controller.reorderStoryPoint('story-1', 1);

    expect(controller.table.storyPoints.map((point) => point.id), [
      'story-2',
      'story-1',
    ]);
    expect(controller.table.storyPoints.last.order, 1);
  });

  test('notas do jogador sao salvas e removidas da ficha', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    final characterId = controller.characters.first.id;
    final now = DateTime(2026, 6, 4, 12);
    final note = CampaignNote(
      id: 'note-player',
      createdAt: now,
      updatedAt: now,
      title: 'Pista',
      body: 'Porta secreta',
    );

    controller.upsertCharacterNote(characterId, note);
    expect(controller.characters.first.notes.single.body, 'Porta secreta');

    controller.deleteCharacterNote(characterId, note.id);
    expect(controller.characters.first.notes, isEmpty);
  });

  test('monstro adicionado ao combate guarda referencia oficial', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);
    const monster = MonsterTemplate(
      id: 'goblin',
      name: 'Goblin',
      category: 'Fraco',
      defense: 11,
      maxHp: 5,
      attack: '1d20',
      damage: '1d4',
      movement: 'Rápido',
      instinct: 'Emboscar',
      special: 'Fuga',
      description: 'Pequeno e sorrateiro',
    );

    controller.startCombat();
    controller.addMonsterToCombat(monster, 1);

    final participant = controller.activeCombat!.participants
        .where((item) => item.type == ParticipantType.monster)
        .single;
    expect(participant.sourceMonsterId, 'goblin');
  });

  test('arma ativa do jogador em combate fica no participante', () {
    final controller = RpgSessionController.seeded();
    addTearDown(controller.dispose);

    controller.startCombat();
    final participant = controller.activeCombat!.participants
        .where((item) => item.type == ParticipantType.player)
        .first;

    controller.setParticipantActiveWeaponSlot(
      participant.id,
      ActiveWeaponSlot.secondary,
    );

    expect(
      controller.activeCombat!.participants
          .where((item) => item.id == participant.id)
          .single
          .activeWeaponSlot,
      ActiveWeaponSlot.secondary,
    );
  });
}
