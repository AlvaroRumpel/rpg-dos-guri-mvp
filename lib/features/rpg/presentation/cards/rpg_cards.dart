part of '../shell/session_shell.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    required this.character,
    required this.masterMode,
    super.key,
  });

  final CharacterSheet character;
  final bool masterMode;

  @override
  Widget build(BuildContext context) {
    final combatIsActive = context.select<RpgSessionController, bool>(
      (controller) => controller.activeCombat?.active == true,
    );
    final weapon = context.select<RpgSessionController, EquipmentTemplate?>(
      (controller) => controller.equipmentByName(character.mainWeapon),
    );

    return RepaintBoundary(
      child: RpgPanel(
        ornate: true,
        raised: !masterMode,
        borderColor: masterMode ? RpgTheme.line : RpgTheme.lineGold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RpgPortrait(
                  label: character.name,
                  sigil: character.characterClass,
                  size: masterMode ? 46 : 84,
                  color: RpgTheme.lineGold,
                  showLabel: !masterMode,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Nível ${character.level} - ${character.race} ${character.characterClass}',
                        style: const TextStyle(color: RpgTheme.gold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        character.concept,
                        maxLines: masterMode ? 2 : null,
                        overflow: masterMode
                            ? TextOverflow.ellipsis
                            : TextOverflow.visible,
                        style: const TextStyle(
                          color: RpgTheme.mutedInk,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RpgHpBar(current: character.currentHp, max: character.maxHp),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'Vida',
                  value: '${character.currentHp}/${character.maxHp}',
                ),
                _InfoChip(label: 'Defesa', value: '${character.defense}'),
                _InfoChip(label: 'Arma', value: character.mainWeapon),
                if (weapon?.damage != null)
                  _InfoChip(label: 'Dano', value: weapon!.damage!),
                _InfoChip(label: 'Armadura', value: character.armor),
                _InfoChip(label: 'Moedas', value: '${character.coins}'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Atributos: ${_joinStats(character.attributes)}',
              maxLines: masterMode ? 2 : null,
              overflow: masterMode ? TextOverflow.ellipsis : null,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Perícias: ${_joinStats(character.skills)}',
              maxLines: masterMode ? 2 : null,
              overflow: masterMode ? TextOverflow.ellipsis : null,
              style: const TextStyle(fontSize: 12),
            ),
            if (masterMode) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  RpgButton(
                    onPressed: () => _showLevelUpDialog(context, character),
                    icon: Icons.trending_up,
                    label: 'Subir nível',
                    small: true,
                  ),
                  RpgButton(
                    onPressed: () =>
                        _showCharacterForm(context, existing: character),
                    icon: Icons.edit,
                    label: 'Editar ficha',
                    small: true,
                  ),
                  RpgButton(
                    onPressed: () =>
                        _showPowerLibraryDialog(context, character),
                    icon: Icons.auto_stories,
                    label: 'Poderes/magias',
                    small: true,
                  ),
                  RpgButton(
                    onPressed: () => _showInventoryEditor(context, character),
                    icon: Icons.inventory_2,
                    label: 'Inventário',
                    small: true,
                  ),
                  RpgButton(
                    onPressed: () =>
                        _showArchiveCharacterDialog(context, character),
                    icon: Icons.archive,
                    label: 'Arquivar',
                    variant: RpgButtonVariant.ghost,
                    small: true,
                  ),
                ],
              ),
              if (character.powers.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Poderes', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final power in character.powers)
                      ActionChip(
                        avatar: Icon(
                          power.used
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        label: Text(
                          '${power.name} - ${_usageLabel(power.usageLimit)}',
                        ),
                        onPressed: () => context
                            .read<RpgSessionController>()
                            .togglePowerUsed(character.id, power.id),
                      ),
                  ],
                ),
              ],
              if (combatIsActive &&
                  character.inventory.any(
                    (item) => item.effectKind != null && item.quantity > 0,
                  )) ...[
                const SizedBox(height: 10),
                Text(
                  'Consumiveis',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in character.inventory.where(
                      (item) => item.effectKind != null && item.quantity > 0,
                    ))
                      ActionChip(
                        avatar: const Icon(Icons.local_drink),
                        label: Text('${item.name} x${item.quantity}'),
                        onPressed: () =>
                            _showConsumableDialog(context, character, item),
                      ),
                  ],
                ),
              ],
            ],
            if (!masterMode && !combatIsActive) ...[
              const SizedBox(height: 8),
              RpgButton(
                onPressed: () => _showInventoryEditor(context, character),
                icon: Icons.inventory_2,
                label: 'Editar inventario',
                variant: RpgButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PowerCard extends StatelessWidget {
  const PowerCard({required this.character, required this.power, super.key});

  final CharacterSheet character;
  final PowerEntry power;

  @override
  Widget build(BuildContext context) {
    final combatPower = power.usageLimit == UsageLimit.combat;
    return InkWell(
      onTap: () => _showPowerEntryDetails(context, power),
      borderRadius: BorderRadius.circular(RpgRadius.md),
      child: RpgPanel(
        inset: true,
        doubleBorder: combatPower && !power.used,
        borderColor: combatPower ? RpgTheme.ochre : RpgTheme.line,
        ornate: combatPower && !power.used,
        padding: const EdgeInsets.all(RpgSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  power.type.toLowerCase().contains('magia')
                      ? Icons.auto_awesome
                      : Icons.flash_on,
                  color: combatPower ? RpgTheme.ochre : RpgTheme.gold,
                  size: 18,
                ),
                const SizedBox(width: RpgSpacing.sm),
                Expanded(
                  child: Text(
                    power.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (!power.used) ...[
                  const SizedBox(width: RpgSpacing.sm),
                  RpgButton(
                    onPressed: () => context
                        .read<RpgSessionController>()
                        .requestPowerUse(character.id, power.id),
                    label: 'Solicitar',
                    small: true,
                  ),
                ],
              ],
            ),
            const SizedBox(height: RpgSpacing.sm),
            Wrap(
              spacing: RpgSpacing.sm,
              runSpacing: RpgSpacing.sm,
              children: [
                RpgStatChip(label: 'tipo', value: power.type),
                RpgStatChip(label: 'uso', value: _usageLabel(power.usageLimit)),
                if (power.used)
                  const RpgStatChip(label: 'estado', value: 'usado'),
              ],
            ),
            const SizedBox(height: RpgSpacing.sm),
            Text(
              power.suggestedTest,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RpgTextStyles.eyebrow(size: 9),
            ),
            const SizedBox(height: RpgSpacing.xs),
            Text(
              power.effect,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
            ),
            if (power.extraEffect != null || power.notes != null) ...[
              const SizedBox(height: RpgSpacing.xs),
              Text(
                [power.extraEffect, power.notes]
                    .whereType<String>()
                    .where((value) => value.trim().isNotEmpty)
                    .join(' - '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: RpgTheme.inkDim, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RpgStatChip(label: label, value: value);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StatusEntry status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status.type);
    return Chip(
      avatar: Icon(_statusIcon(status.type), color: color, size: 16),
      backgroundColor: color.withValues(alpha: 0.16),
      side: BorderSide(color: color),
      label: Text(
        status.name,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.state});

  final DefeatedState state;

  @override
  Widget build(BuildContext context) {
    final color = _defeatedColor(state);
    return Chip(
      backgroundColor: color.withValues(alpha: 0.18),
      side: BorderSide(color: color),
      label: Text(
        _defeatedLabel(state),
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      borderColor: RpgTheme.lineStrong,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_empty, color: RpgTheme.inkDim),
          const SizedBox(width: 10),
          Flexible(child: Text(message)),
        ],
      ),
    );
  }
}
