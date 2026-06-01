import '../../domain/domain.dart';
import 'official_name_matcher.dart';

class CharacterPowerReconciliationService {
  const CharacterPowerReconciliationService._();

  static List<PowerEntry> reconcile({
    required CharacterSheet previous,
    required CharacterSheet updated,
    required List<RaceTemplate> races,
    required List<ClassProgressionEntry> progression,
    required List<SpellTemplate> spells,
    List<String> selectedMageSpellIds = const [],
  }) {
    final classChanged = !OfficialNameMatcher.same(
      previous.characterClass,
      updated.characterClass,
    );
    final raceChanged = !OfficialNameMatcher.same(previous.race, updated.race);
    if (!classChanged && !raceChanged) return updated.powers;

    if (!classChanged) {
      return _deduplicate([
        ...updated.powers.where((power) => !_isRacial(power)),
        ..._racialPower(updated.race, races),
      ]);
    }

    return _deduplicate([
      ..._racialPower(updated.race, races),
      ...progression
          .where(
            (entry) =>
                entry.level <= updated.level &&
                OfficialNameMatcher.same(
                  entry.characterClass,
                  updated.characterClass,
                ),
          )
          .map((entry) => entry.toPowerEntry()),
      if (OfficialNameMatcher.same(updated.characterClass, 'Mago'))
        ..._mageSpells(spells, selectedMageSpellIds),
    ]);
  }

  static List<PowerEntry> _racialPower(String race, List<RaceTemplate> races) {
    final template = OfficialNameMatcher.firstWhereOrNull(
      races,
      (item) => OfficialNameMatcher.same(item.name, race),
    );
    return template == null ? const [] : [template.toPowerEntry()];
  }

  static Iterable<PowerEntry> _mageSpells(
    List<SpellTemplate> spells,
    List<String> selectedSpellIds,
  ) sync* {
    const initialSpellIds = {
      'bola-de-fogo-pequena',
      'raio-arcano',
      'luz-magica',
    };
    for (final spell in spells) {
      if (initialSpellIds.contains(spell.id)) yield spell.toEntry();
    }
    final initialStrong = OfficialNameMatcher.firstWhereOrNull(
      spells,
      (spell) => spell.usageLimit == UsageLimit.combat,
    );
    if (initialStrong != null) yield initialStrong.toEntry();
    for (final id in selectedSpellIds) {
      final spell = OfficialNameMatcher.firstWhereOrNull(
        spells,
        (item) => item.id == id,
      );
      if (spell != null) yield spell.toEntry();
    }
  }

  static bool _isRacial(PowerEntry power) {
    return OfficialNameMatcher.canonical(power.type).contains('racial') ||
        OfficialNameMatcher.canonical(power.origin ?? '').contains('raca');
  }

  static List<PowerEntry> _deduplicate(Iterable<PowerEntry> powers) {
    final names = <String>{};
    return [
      for (final power in powers)
        if (names.add(OfficialNameMatcher.canonical(power.name))) power,
    ];
  }
}
