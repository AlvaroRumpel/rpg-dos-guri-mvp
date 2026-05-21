import 'combat_participant.dart';

class CombatState {
  const CombatState({
    required this.id,
    required this.active,
    required this.round,
    required this.participants,
  });

  final String id;
  final bool active;
  final int round;
  final List<CombatParticipant> participants;

  CombatState copyWith({
    bool? active,
    int? round,
    List<CombatParticipant>? participants,
  }) {
    return CombatState(
      id: id,
      active: active ?? this.active,
      round: round ?? this.round,
      participants: participants ?? this.participants,
    );
  }
}
