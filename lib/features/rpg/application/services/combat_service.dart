import '../../domain/domain.dart';

class CombatService {
  const CombatService._();

  static CombatParticipant participantFromCharacter(CharacterSheet character) {
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
}
