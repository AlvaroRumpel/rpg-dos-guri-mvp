const _unset = Object();

class RpgTable {
  const RpgTable({
    required this.id,
    required this.name,
    required this.code,
    this.pendingPlayerNames = const [],
    this.activeCombatId,
  });

  final String id;
  final String name;
  final String code;
  final List<String> pendingPlayerNames;
  final String? activeCombatId;

  RpgTable copyWith({
    String? name,
    String? code,
    List<String>? pendingPlayerNames,
    Object? activeCombatId = _unset,
  }) {
    return RpgTable(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      pendingPlayerNames: pendingPlayerNames ?? this.pendingPlayerNames,
      activeCombatId: identical(activeCombatId, _unset)
          ? this.activeCombatId
          : activeCombatId as String?,
    );
  }
}
