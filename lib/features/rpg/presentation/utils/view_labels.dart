part of '../shell/session_shell.dart';

Color _defeatedColor(DefeatedState state) {
  return switch (state) {
    DefeatedState.active => RpgTheme.moss,
    DefeatedState.unconscious => RpgTheme.ochre,
    DefeatedState.defeated => RpgTheme.danger,
    DefeatedState.dead => RpgTheme.charcoal,
  };
}

Color _statusColor(String type) {
  return switch (type) {
    'Condicao' => RpgTheme.ochre,
    'Bonus' => RpgTheme.moss,
    'Penalidade' => RpgTheme.danger,
    'Vantagem' => RpgTheme.brass,
    'Desvantagem' => RpgTheme.wine,
    _ => RpgTheme.mutedInk,
  };
}

String _equipmentCategoryLabel(EquipmentCategory category) {
  return switch (category) {
    EquipmentCategory.weapon => 'Arma',
    EquipmentCategory.shield => 'Escudo',
    EquipmentCategory.armor => 'Armadura',
    EquipmentCategory.accessory => 'Acessório',
  };
}

IconData _equipmentIcon(EquipmentCategory category) {
  return switch (category) {
    EquipmentCategory.weapon => Icons.gavel,
    EquipmentCategory.shield => Icons.shield,
    EquipmentCategory.armor => Icons.health_and_safety,
    EquipmentCategory.accessory => Icons.diamond,
  };
}

IconData _powerIcon(String type) {
  final lower = type.toLowerCase();
  if (lower.contains('racial')) return Icons.workspace_premium;
  if (lower.contains('classe')) return Icons.military_tech;
  if (lower.contains('divino')) return Icons.wb_sunny;
  return Icons.auto_awesome;
}

IconData _statusIcon(String type) {
  return switch (type) {
    'Condicao' => Icons.warning_amber,
    'Bonus' => Icons.arrow_upward,
    'Penalidade' => Icons.arrow_downward,
    'Vantagem' => Icons.add_circle_outline,
    'Desvantagem' => Icons.remove_circle_outline,
    _ => Icons.label_outline,
  };
}

String _usageLabel(UsageLimit limit) {
  return switch (limit) {
    UsageLimit.free => 'Livre',
    UsageLimit.combat => '1x por combate',
    UsageLimit.session => '1x por sessão',
    UsageLimit.longRest => '1x por descanso longo',
  };
}

String _usageLimitLabel(UsageLimit limit) => _usageLabel(limit);

String _effectKindLabel(String value) {
  return switch (value) {
    'heal' => 'Cura',
    'damage' => 'Dano',
    _ => value,
  };
}

String _defeatedLabel(DefeatedState state) {
  return switch (state) {
    DefeatedState.active => 'Ativo',
    DefeatedState.unconscious => 'Inconsciente',
    DefeatedState.defeated => 'Derrotado',
    DefeatedState.dead => 'Morto',
  };
}

String _participantTypeLabel(ParticipantType type) {
  return switch (type) {
    ParticipantType.player => 'Jogador',
    ParticipantType.monster => 'Monstro',
    ParticipantType.npcAlly => 'NPC aliado',
    ParticipantType.npcNeutral => 'NPC neutro',
    ParticipantType.npcEnemy => 'NPC inimigo',
    ParticipantType.object => 'Objeto relevante',
  };
}

String _participantSigil(CombatParticipant participant) {
  return switch (participant.type) {
    ParticipantType.player => 'shield',
    ParticipantType.monster => 'skull',
    ParticipantType.npcAlly => 'shield',
    ParticipantType.npcNeutral => 'rune',
    ParticipantType.npcEnemy => 'skull',
    ParticipantType.object => 'rune',
  };
}
