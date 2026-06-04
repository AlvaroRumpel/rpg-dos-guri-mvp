import 'campaign_note.dart';
import 'custom_npc.dart';
import 'power_use_request.dart';
import 'story_point.dart';

const _unset = Object();

class RpgTable {
  const RpgTable({
    required this.id,
    required this.name,
    required this.code,
    this.pendingPlayerNames = const [],
    this.powerUseRequests = const [],
    this.masterNotes = const [],
    this.storyPoints = const [],
    this.customNpcs = const [],
    this.masterPinHash,
    this.activeCombatId,
  });

  final String id;
  final String name;
  final String code;
  final List<String> pendingPlayerNames;
  final List<PowerUseRequest> powerUseRequests;
  final List<CampaignNote> masterNotes;
  final List<StoryPoint> storyPoints;
  final List<CustomNpc> customNpcs;
  final String? masterPinHash;
  final String? activeCombatId;

  RpgTable copyWith({
    String? name,
    String? code,
    List<String>? pendingPlayerNames,
    List<PowerUseRequest>? powerUseRequests,
    List<CampaignNote>? masterNotes,
    List<StoryPoint>? storyPoints,
    List<CustomNpc>? customNpcs,
    Object? masterPinHash = _unset,
    Object? activeCombatId = _unset,
  }) {
    return RpgTable(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      pendingPlayerNames: pendingPlayerNames ?? this.pendingPlayerNames,
      powerUseRequests: powerUseRequests ?? this.powerUseRequests,
      masterNotes: masterNotes ?? this.masterNotes,
      storyPoints: storyPoints ?? this.storyPoints,
      customNpcs: customNpcs ?? this.customNpcs,
      masterPinHash: identical(masterPinHash, _unset)
          ? this.masterPinHash
          : masterPinHash as String?,
      activeCombatId: identical(activeCombatId, _unset)
          ? this.activeCombatId
          : activeCombatId as String?,
    );
  }
}
