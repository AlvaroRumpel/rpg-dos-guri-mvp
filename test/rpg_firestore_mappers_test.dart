import 'package:flutter_test/flutter_test.dart';

import 'package:rpg_dos_guri/features/rpg/data/rpg_firestore_mappers.dart';
import 'package:rpg_dos_guri/features/rpg/domain/domain.dart';

void main() {
  test('mappers usam fallback vazio para novos campos', () {
    final table = tableFromMap('mesa', {'name': 'Mesa', 'code': 'GURI-1234'});
    final character = characterFromMap('hero', {
      'name': 'Heroi',
      'race': 'Humano',
      'characterClass': 'Guerreiro',
      'level': 1,
      'currentHp': 10,
    });
    final combat = combatFromMap('combat', {
      'active': true,
      'round': 1,
      'participants': [
        {
          'id': 'monster-1',
          'name': 'Goblin',
          'type': 'monster',
          'currentHp': 4,
          'maxHp': 4,
          'defense': 10,
        },
      ],
    });

    expect(table.masterNotes, isEmpty);
    expect(table.storyPoints, isEmpty);
    expect(table.customNpcs, isEmpty);
    expect(character.notes, isEmpty);
    expect(combat.participants.single.sourceMonsterId, isNull);
    expect(
      combat.participants.single.activeWeaponSlot,
      ActiveWeaponSlot.primary,
    );
  });

  test('mappers persistem notas historia npcs e sourceMonsterId', () {
    final now = DateTime(2026, 6, 4, 12);
    final table = RpgTable(
      id: 'mesa',
      name: 'Mesa',
      code: 'GURI-1234',
      masterNotes: [
        CampaignNote(
          id: 'note',
          createdAt: now,
          updatedAt: now,
          title: 'Nota',
          body: '@Heroi',
        ),
      ],
      storyPoints: [
        StoryPoint(
          id: 'story',
          createdAt: now,
          updatedAt: now,
          title: 'Ideia',
          body: '@NPC',
          order: 0,
        ),
      ],
      customNpcs: [
        CustomNpc(
          id: 'npc',
          createdAt: now,
          updatedAt: now,
          name: 'NPC',
          occupation: 'Ferreiro',
        ),
      ],
    );
    final character = CharacterSheet(
      id: 'hero',
      name: 'Heroi',
      race: 'Humano',
      characterClass: 'Guerreiro',
      level: 1,
      concept: '',
      attributes: const {},
      skills: const {},
      currentHp: 10,
      armor: 'Sem armadura',
      hasShield: false,
      mainWeapon: 'Adaga',
      secondaryItem: '',
      accessories: const [],
      powers: const [],
      inventory: const [],
      statuses: const [],
      coins: 0,
      notes: [
        CampaignNote(
          id: 'player-note',
          createdAt: now,
          updatedAt: now,
          title: 'Pista',
          body: 'Porta',
        ),
      ],
    );
    const participant = CombatParticipant(
      id: 'monster-1',
      name: 'Goblin',
      type: ParticipantType.monster,
      currentHp: 4,
      maxHp: 4,
      defense: 10,
      statuses: [],
      sourceMonsterId: 'goblin',
      activeWeaponSlot: ActiveWeaponSlot.secondary,
    );

    expect(
      tableFromMap('mesa', tableToMap(table)).customNpcs.single.name,
      'NPC',
    );
    expect(
      characterFromMap('hero', characterToMap(character)).notes.single.title,
      'Pista',
    );
    expect(
      combatParticipantFromMap(
        combatParticipantToMap(participant),
      ).sourceMonsterId,
      'goblin',
    );
    expect(
      combatParticipantFromMap(
        combatParticipantToMap(participant),
      ).activeWeaponSlot,
      ActiveWeaponSlot.secondary,
    );
  });
}
