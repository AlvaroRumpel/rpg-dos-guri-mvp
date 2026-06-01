import 'package:flutter_test/flutter_test.dart';

import 'package:rpg_dos_guri/features/rpg/application/application.dart';
import 'package:rpg_dos_guri/features/rpg/domain/domain.dart';

void main() {
  const serviceCharacter = CharacterSheet(
    id: 'hero',
    name: 'Heroi',
    race: 'Humano',
    characterClass: 'Guerreiro',
    level: 3,
    concept: '',
    attributes: {},
    skills: {},
    currentHp: 10,
    armor: 'Sem armadura',
    hasShield: false,
    mainWeapon: '',
    secondaryItem: '',
    accessories: [],
    powers: [
      PowerEntry(
        id: 'old-class',
        name: 'Golpe Poderoso',
        type: 'Habilidade de classe',
        description: '',
        suggestedTest: '',
        effect: '',
        usageLimit: UsageLimit.combat,
      ),
      PowerEntry(
        id: 'manual',
        name: 'Poder manual',
        type: 'Poder',
        description: '',
        suggestedTest: '',
        effect: '',
        usageLimit: UsageLimit.free,
      ),
    ],
    inventory: [],
    statuses: [],
    coins: 0,
  );

  test('troca de classe reconstrói poderes oficiais até o nível atual', () {
    final powers = CharacterPowerReconciliationService.reconcile(
      previous: serviceCharacter,
      updated: serviceCharacter.copyWith(characterClass: 'Ladino'),
      races: const [_human],
      progression: const [_warriorOne, _rogueOne, _rogueTwo, _rogueThree],
      spells: const [],
    );

    expect(powers.map((power) => power.name), [
      'Determinação Humana',
      'Ataque Furtivo',
      'Esquiva',
      'Truque Sujo',
    ]);
  });

  test('troca apenas de raça preserva poderes não raciais', () {
    final powers = CharacterPowerReconciliationService.reconcile(
      previous: serviceCharacter.copyWith(
        powers: [_human.toPowerEntry(), ...serviceCharacter.powers],
      ),
      updated: serviceCharacter.copyWith(
        race: 'Elfo',
        powers: [_human.toPowerEntry(), ...serviceCharacter.powers],
      ),
      races: const [_human, _elf],
      progression: const [],
      spells: const [],
    );

    expect(powers.map((power) => power.name), [
      'Golpe Poderoso',
      'Poder manual',
      'Reflexo Élfico',
    ]);
  });

  test('troca para mago inclui escolhas adicionais sem duplicar magia', () {
    final powers = CharacterPowerReconciliationService.reconcile(
      previous: serviceCharacter,
      updated: serviceCharacter.copyWith(characterClass: 'Mago'),
      races: const [_human],
      progression: const [],
      spells: const [_simpleSpell, _strongSpell],
      selectedMageSpellIds: const ['luz-magica', 'luz-magica'],
    );

    expect(powers.where((power) => power.name == 'Luz Mágica'), hasLength(1));
    expect(powers.any((power) => power.name == 'Explosão Arcana'), isTrue);
  });
}

const _human = RaceTemplate(
  id: 'humano',
  name: 'Humano',
  identity: '',
  powerName: 'Determinação Humana',
  powerDescription: '',
  powerEffect: '',
  usageLimit: UsageLimit.session,
);

const _elf = RaceTemplate(
  id: 'elfo',
  name: 'Elfo',
  identity: '',
  powerName: 'Reflexo Élfico',
  powerDescription: '',
  powerEffect: '',
  usageLimit: UsageLimit.combat,
);

const _warriorOne = ClassProgressionEntry(
  id: 'guerreiro-1',
  characterClass: 'Guerreiro',
  level: 1,
  name: 'Golpe Poderoso',
  description: '',
  usageLimit: UsageLimit.combat,
);

const _rogueOne = ClassProgressionEntry(
  id: 'ladino-1',
  characterClass: 'Ladino',
  level: 1,
  name: 'Ataque Furtivo',
  description: '',
  usageLimit: UsageLimit.combat,
);

const _rogueTwo = ClassProgressionEntry(
  id: 'ladino-2',
  characterClass: 'Ladino',
  level: 2,
  name: 'Esquiva',
  description: '',
  usageLimit: UsageLimit.combat,
);

const _rogueThree = ClassProgressionEntry(
  id: 'ladino-3',
  characterClass: 'Ladino',
  level: 3,
  name: 'Truque Sujo',
  description: '',
  usageLimit: UsageLimit.combat,
);

const _simpleSpell = SpellTemplate(
  id: 'luz-magica',
  name: 'Luz Mágica',
  tier: 'Magia simples',
  description: '',
  suggestedTest: '',
  effect: '',
  usageLimit: UsageLimit.free,
);

const _strongSpell = SpellTemplate(
  id: 'explosao-arcana',
  name: 'Explosão Arcana',
  tier: 'Magia forte',
  description: '',
  suggestedTest: '',
  effect: '',
  usageLimit: UsageLimit.combat,
);
