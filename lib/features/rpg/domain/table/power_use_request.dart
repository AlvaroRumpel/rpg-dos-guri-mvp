import '../shared/rpg_enums.dart';

class PowerUseRequest {
  const PowerUseRequest({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.powerId,
    required this.powerName,
    required this.usageLimit,
    required this.createdAt,
  });

  final String id;
  final String characterId;
  final String characterName;
  final String powerId;
  final String powerName;
  final UsageLimit usageLimit;
  final DateTime createdAt;
}
