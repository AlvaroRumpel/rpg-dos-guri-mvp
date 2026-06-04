import '../shared/rpg_enums.dart';
import 'status_entry.dart';

const _unset = Object();

class CombatParticipant {
  const CombatParticipant({
    required this.id,
    required this.name,
    required this.type,
    required this.currentHp,
    required this.maxHp,
    required this.defense,
    required this.statuses,
    this.sourceCharacterId,
    this.sourceMonsterId,
    this.damageSuggestion,
    this.defeatedState = DefeatedState.active,
    this.activeWeaponSlot = ActiveWeaponSlot.primary,
  });

  final String id;
  final String name;
  final ParticipantType type;
  final int currentHp;
  final int maxHp;
  final int defense;
  final List<StatusEntry> statuses;
  final String? sourceCharacterId;
  final String? sourceMonsterId;
  final String? damageSuggestion;
  final DefeatedState defeatedState;
  final ActiveWeaponSlot activeWeaponSlot;

  CombatParticipant copyWith({
    String? name,
    ParticipantType? type,
    int? currentHp,
    int? maxHp,
    int? defense,
    List<StatusEntry>? statuses,
    Object? sourceCharacterId = _unset,
    Object? sourceMonsterId = _unset,
    String? damageSuggestion,
    DefeatedState? defeatedState,
    ActiveWeaponSlot? activeWeaponSlot,
  }) {
    return CombatParticipant(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      defense: defense ?? this.defense,
      statuses: statuses ?? this.statuses,
      sourceCharacterId: identical(sourceCharacterId, _unset)
          ? this.sourceCharacterId
          : sourceCharacterId as String?,
      sourceMonsterId: identical(sourceMonsterId, _unset)
          ? this.sourceMonsterId
          : sourceMonsterId as String?,
      damageSuggestion: damageSuggestion ?? this.damageSuggestion,
      defeatedState: defeatedState ?? this.defeatedState,
      activeWeaponSlot: activeWeaponSlot ?? this.activeWeaponSlot,
    );
  }
}
