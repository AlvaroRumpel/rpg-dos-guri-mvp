import 'power_use_request.dart';

const _unset = Object();

class RpgTable {
  const RpgTable({
    required this.id,
    required this.name,
    required this.code,
    this.pendingPlayerNames = const [],
    this.powerUseRequests = const [],
    this.masterPinHash,
    this.activeCombatId,
  });

  final String id;
  final String name;
  final String code;
  final List<String> pendingPlayerNames;
  final List<PowerUseRequest> powerUseRequests;
  final String? masterPinHash;
  final String? activeCombatId;

  RpgTable copyWith({
    String? name,
    String? code,
    List<String>? pendingPlayerNames,
    List<PowerUseRequest>? powerUseRequests,
    Object? masterPinHash = _unset,
    Object? activeCombatId = _unset,
  }) {
    return RpgTable(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      pendingPlayerNames: pendingPlayerNames ?? this.pendingPlayerNames,
      powerUseRequests: powerUseRequests ?? this.powerUseRequests,
      masterPinHash: identical(masterPinHash, _unset)
          ? this.masterPinHash
          : masterPinHash as String?,
      activeCombatId: identical(activeCombatId, _unset)
          ? this.activeCombatId
          : activeCombatId as String?,
    );
  }
}
