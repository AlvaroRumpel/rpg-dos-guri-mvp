part of '../shell/session_shell.dart';

class CombatPanel extends StatelessWidget {
  const CombatPanel({required this.combat, super.key});

  final CombatState combat;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RpgSessionController>();
    final players = combat.participants.where(
      (item) => item.type == ParticipantType.player,
    );
    final others = combat.participants.where(
      (item) => item.type != ParticipantType.player,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RpgPanel(
          ornate: true,
          borderColor: RpgTheme.lineGold,
          danger: true,
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: RpgTheme.danger),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMBATE ATIVO',
                      style: RpgTextStyles.eyebrow(
                        color: RpgTheme.danger,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'Encontro em andamento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              RpgIconButton(
                onPressed: () => controller.changeRound(-1),
                icon: Icons.remove,
                tooltip: 'Voltar rodada',
              ),
              const SizedBox(width: 8),
              Text(
                combat.round.toString().padLeft(2, '0'),
                style: RpgTextStyles.mono(
                  size: 22,
                  color: RpgTheme.goldBright,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              RpgIconButton(
                onPressed: () => controller.changeRound(1),
                icon: Icons.add,
                tooltip: 'Proxima rodada',
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    RpgButton(
                      onPressed: controller.addMissingPlayersToCombat,
                      icon: Icons.group_add,
                      label: 'Jogadores',
                      small: true,
                    ),
                    RpgButton(
                      onPressed: () => _showMonsterPicker(context),
                      icon: Icons.add_circle,
                      label: 'Monstro',
                      small: true,
                    ),
                    RpgButton(
                      onPressed: () => _showCustomParticipantDialog(context),
                      icon: Icons.person_add_alt_1,
                      label: 'NPC/objeto',
                      small: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 860;
            final children = [
              _ParticipantSection(
                title: 'Jogadores',
                participants: players.toList(),
              ),
              _ParticipantSection(
                title: 'Monstros e NPCs',
                participants: others.toList(),
              ),
            ];
            if (!wide) return Column(children: children);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final child in children)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: child,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ParticipantSection extends StatelessWidget {
  const _ParticipantSection({required this.title, required this.participants});

  final String title;
  final List<CombatParticipant> participants;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RpgSectionTitle(
          title: title,
          subtitle: '${participants.length} participantes',
          icon: title == 'Jogadores' ? Icons.shield : Icons.psychology_alt,
          accent: title == 'Jogadores' ? RpgTheme.gold : RpgTheme.danger,
        ),
        const SizedBox(height: 8),
        if (participants.isEmpty)
          const _EmptyState(message: 'Nenhum participante.')
        else
          for (final participant in participants)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ParticipantCard(participant: participant),
            ),
      ],
    );
  }
}

class ParticipantCard extends StatelessWidget {
  const ParticipantCard({required this.participant, super.key});

  final CombatParticipant participant;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RpgSessionController>();
    final isDanger =
        participant.type == ParticipantType.monster ||
        participant.type == ParticipantType.npcEnemy;
    final accent = isDanger
        ? RpgTheme.danger
        : participant.type == ParticipantType.player
        ? RpgTheme.gold
        : RpgTheme.mossBright;
    final sourceCharacter = participant.sourceCharacterId == null
        ? null
        : controller.characterById(participant.sourceCharacterId!);
    final sourceMonster = participant.sourceMonsterId == null
        ? null
        : controller.monsterById(participant.sourceMonsterId!);
    final selectedWeapon = sourceCharacter == null
        ? null
        : _selectedCombatWeapon(controller, sourceCharacter, participant);

    final inactive = participant.defeatedState != DefeatedState.active;

    return InkWell(
      onTap: () {
        if (sourceCharacter != null) {
          _showCharacterSummaryDialog(context, sourceCharacter);
        } else if (sourceMonster != null) {
          _showMonsterTemplateDetails(context, sourceMonster);
        } else {
          _showParticipantSummaryDialog(context, participant);
        }
      },
      borderRadius: BorderRadius.circular(RpgRadius.md),
      child: RpgPanel(
        borderColor: inactive ? RpgTheme.lineStrong : accent,
        danger: isDanger,
        child: Stack(
          children: [
            if (inactive)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: RpgTheme.bgDeep.withValues(alpha: 0.38),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: RpgStateLamp(state: participant.defeatedState),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    RpgPortrait(
                      label: participant.name,
                      sigil: isDanger
                          ? 'skull'
                          : _participantSigil(participant),
                      size: 46,
                      color: accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant.name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _participantTypeLabel(
                                  participant.type,
                                ).toUpperCase(),
                                style: RpgTextStyles.eyebrow(
                                  color: RpgTheme.inkDim,
                                  size: 9,
                                ),
                              ),
                              Text(
                                'DEF ${participant.defense}',
                                style: RpgTextStyles.mono(
                                  color: RpgTheme.mutedInk,
                                  size: 11,
                                ),
                              ),
                              if (participant.damageSuggestion != null)
                                Text(
                                  participant.damageSuggestion!,
                                  style: RpgTextStyles.mono(
                                    color: RpgTheme.ochre,
                                    size: 11,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RpgHpBar(
                  current: participant.currentHp,
                  max: participant.maxHp,
                ),
                if (selectedWeapon != null) ...[
                  const SizedBox(height: 10),
                  _CombatWeaponPanel(
                    weapon: selectedWeapon,
                    onToggle: () => controller.setParticipantActiveWeaponSlot(
                      participant.id,
                      participant.activeWeaponSlot == ActiveWeaponSlot.primary
                          ? ActiveWeaponSlot.secondary
                          : ActiveWeaponSlot.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final status in participant.statuses)
                      _StatusChip(status: status),
                    if (participant.statuses.isEmpty)
                      const Text(
                        'Sem status',
                        style: TextStyle(color: RpgTheme.inkDim, fontSize: 12),
                      ),
                  ],
                ),
                if (sourceCharacter != null &&
                    sourceCharacter.powers.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final power in sourceCharacter.powers)
                        ActionChip(
                          avatar: Icon(
                            power.used
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 16,
                          ),
                          label: Text(
                            '${power.name} (${power.used ? 'usado' : 'disponível'})',
                          ),
                          onPressed: () =>
                              _showPowerEntryDetails(context, power),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    RpgButton(
                      onPressed: () => _showValueDialog(
                        context,
                        title: 'Aplicar dano',
                        target: participant,
                        mode: _ValueDialogMode.damage,
                        onConfirm: (value) =>
                            controller.applyDamage(participant.id, value),
                      ),
                      icon: Icons.remove_circle,
                      label: 'Dano',
                      variant: RpgButtonVariant.danger,
                      small: true,
                    ),
                    RpgButton(
                      onPressed: () => _showValueDialog(
                        context,
                        title: 'Aplicar cura',
                        target: participant,
                        mode: _ValueDialogMode.heal,
                        onConfirm: (value) =>
                            controller.applyHeal(participant.id, value),
                      ),
                      icon: Icons.add_circle,
                      label: 'Cura',
                      variant: RpgButtonVariant.primary,
                      small: true,
                    ),
                    RpgButton(
                      onPressed: () => _showStatusDialog(context, participant),
                      icon: Icons.label,
                      label: 'Status',
                      small: true,
                    ),
                    RpgButton(
                      onPressed: () =>
                          _showParticipantEditDialog(context, participant),
                      icon: Icons.edit,
                      label: 'Editar',
                      small: true,
                    ),
                    RpgButton(
                      onPressed: () =>
                          _showDefeatedStateDialog(context, participant),
                      icon: Icons.more_horiz,
                      label: 'Estado',
                      small: true,
                    ),
                  ],
                ),
              ],
            ),
            if (participant.defeatedState == DefeatedState.unconscious)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: RpgTheme.ochre),
                      boxShadow: [
                        BoxShadow(
                          color: RpgTheme.ochre.withValues(alpha: 0.18),
                          blurRadius: 24,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CombatWeaponPanel extends StatelessWidget {
  const _CombatWeaponPanel({required this.weapon, required this.onToggle});

  final _CombatWeaponInfo weapon;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      inset: true,
      padding: const EdgeInsets.all(8),
      borderColor: RpgTheme.lineGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                weapon.isShield ? Icons.security : Icons.gavel,
                color: RpgTheme.goldBright,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weapon.name,
                  overflow: TextOverflow.ellipsis,
                  style: RpgTextStyles.button(
                    size: 11,
                    color: RpgTheme.inkBright,
                  ),
                ),
              ),
              RpgButton(
                onPressed: onToggle,
                icon: Icons.swap_horiz,
                label: weapon.slot == ActiveWeaponSlot.primary
                    ? 'Principal'
                    : 'SecundÃ¡ria',
                small: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              RpgStatChip(
                label: weapon.isShield ? 'defesa' : 'dano',
                value: weapon.value,
              ),
              RpgStatChip(label: 'atributo', value: weapon.attribute),
              if (weapon.properties.isNotEmpty)
                RpgStatChip(
                  label: 'propriedades',
                  value: weapon.properties.join(', '),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CombatWeaponInfo {
  const _CombatWeaponInfo({
    required this.slot,
    required this.name,
    required this.value,
    required this.attribute,
    required this.properties,
    required this.isShield,
  });

  final ActiveWeaponSlot slot;
  final String name;
  final String value;
  final String attribute;
  final List<String> properties;
  final bool isShield;
}

_CombatWeaponInfo _selectedCombatWeapon(
  RpgSessionController controller,
  CharacterSheet character,
  CombatParticipant participant,
) {
  final secondary = controller.equipmentByName(character.secondaryItem);
  final primary = controller.equipmentByName(character.mainWeapon);
  final useSecondary =
      participant.activeWeaponSlot == ActiveWeaponSlot.secondary &&
      secondary != null;
  final equipment = useSecondary ? secondary : primary;
  final slot = useSecondary
      ? ActiveWeaponSlot.secondary
      : ActiveWeaponSlot.primary;
  final name = useSecondary ? character.secondaryItem : character.mainWeapon;
  final isShield = equipment?.category == EquipmentCategory.shield;
  return _CombatWeaponInfo(
    slot: slot,
    name: name.trim().isEmpty ? 'Sem equipamento' : name,
    value: isShield
        ? '+${equipment?.defenseBonus ?? 0}'
        : equipment?.damage ?? '-',
    attribute: equipment?.attribute ?? '-',
    properties: equipment?.properties ?? const [],
    isShield: isShield,
  );
}
