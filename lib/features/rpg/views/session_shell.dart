import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rpg_theme.dart';
import '../models/rpg_models.dart';
import '../state/rpg_session_controller.dart';

class SessionShell extends StatelessWidget {
  const SessionShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RpgSessionController>();

    return switch (controller.role) {
      UserRole.master => const MasterView(),
      UserRole.player => const PlayerView(),
      UserRole.landing => const LandingView(),
    };
  }
}

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RpgSessionController>();

    return Scaffold(
      appBar: AppBar(title: const Text('RPG dos Guri')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      controller.table.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Codigo ${controller.table.code}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre como mestre ou escolha uma ficha aprovada. Sem login, feito para uso em casa.',
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _showTableCodeDialog(context),
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('Entrar/criar mesa por codigo'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: controller.enterAsMaster,
                      icon: const Icon(Icons.shield),
                      label: const Text('Entrar como mestre'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Jogadores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final character in controller.characters)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () =>
                              controller.enterAsPlayer(character.id),
                          child: Text(
                            '${character.name} - ${character.race} ${character.characterClass}',
                          ),
                        ),
                      ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showJoinRequestDialog(context),
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Solicitar entrada como jogador'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MasterView extends StatelessWidget {
  const MasterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RpgSessionController>();
    final combat = controller.activeCombat;

    return Scaffold(
      appBar: AppBar(
        title: Text('${controller.table.name} - Mestre'),
        actions: [
          TextButton.icon(
            onPressed: controller.backToLanding,
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: controller.startCombat,
                icon: const Icon(Icons.shield),
                label: Text(
                  combat == null || !combat.active
                      ? 'Iniciar combate'
                      : 'Reiniciar combate',
                ),
              ),
              if (combat != null && combat.active)
                OutlinedButton.icon(
                  onPressed: controller.finishCombat,
                  icon: const Icon(Icons.flag),
                  label: const Text('Finalizar combate'),
                ),
              OutlinedButton.icon(
                onPressed: () => _showCharacterForm(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Nova ficha'),
              ),
              OutlinedButton.icon(
                onPressed: () => _showTableDialog(context),
                icon: const Icon(Icons.settings),
                label: const Text('Mesa'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.pendingPlayerNames.isNotEmpty) ...[
            Text(
              'Aprovacoes pendentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final playerName in controller.pendingPlayerNames)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_add),
                    title: Text(playerName),
                    subtitle: const Text(
                      'Ao aprovar, uma ficha inicial sera criada para esse jogador.',
                    ),
                    trailing: FilledButton(
                      onPressed: () => controller.approvePlayer(playerName),
                      child: const Text('Aprovar'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (combat == null || !combat.active)
            const _EmptyState(
              message:
                  'Inicie um combate para controlar vida, status e monstros.',
            )
          else
            CombatPanel(combat: combat),
          const SizedBox(height: 16),
          Text('Fichas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final character in controller.characters)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CharacterCard(character: character, masterMode: true),
            ),
          const SizedBox(height: 16),
          Text(
            'Registro informativo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: controller.actionLog.isEmpty
                  ? const Text('Sem eventos ainda.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.actionLog
                          .map((item) => Text(item))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton.outlined(
                  onPressed: () => controller.changeRound(-1),
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  'Rodada ${combat.round}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton.outlined(
                  onPressed: () => controller.changeRound(1),
                  icon: const Icon(Icons.add),
                ),
                OutlinedButton.icon(
                  onPressed: controller.addMissingPlayersToCombat,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Adicionar jogadores'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showMonsterPicker(context),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Adicionar monstro'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showCustomParticipantDialog(context),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('NPC/objeto'),
                ),
              ],
            ),
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
        Text(title, style: Theme.of(context).textTheme.titleMedium),
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
    final percent = participant.maxHp == 0
        ? 0.0
        : participant.currentHp / participant.maxHp;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    participant.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StateChip(state: participant.defeatedState),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Vida ${participant.currentHp}/${participant.maxHp} - Defesa ${participant.defense}',
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0).toDouble(),
              color: _hpColor(percent),
              borderRadius: BorderRadius.circular(999),
              minHeight: 8,
            ),
            if (participant.damageSuggestion != null) ...[
              const SizedBox(height: 6),
              Text('Dano sugerido: ${participant.damageSuggestion}'),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final status in participant.statuses)
                  _StatusChip(status: status),
                if (participant.statuses.isEmpty) const Text('Sem status'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showValueDialog(
                    context,
                    title: 'Aplicar dano',
                    onConfirm: (value) =>
                        controller.applyDamage(participant.id, value),
                  ),
                  icon: const Icon(Icons.remove_circle),
                  label: const Text('Dano'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showValueDialog(
                    context,
                    title: 'Aplicar cura',
                    onConfirm: (value) =>
                        controller.applyHeal(participant.id, value),
                  ),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Cura'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showStatusDialog(context, participant),
                  icon: const Icon(Icons.label),
                  label: const Text('Status'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _showParticipantEditDialog(context, participant),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
                DropdownButton<DefeatedState>(
                  value: participant.defeatedState,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setDefeatedState(participant.id, value);
                    }
                  },
                  items: DefeatedState.values
                      .map(
                        (state) => DropdownMenuItem(
                          value: state,
                          child: Text(_defeatedLabel(state)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RpgSessionController>();
    final character = controller.selectedCharacter;

    return Scaffold(
      appBar: AppBar(
        title: Text(character == null ? 'Jogador' : character.name),
        actions: [
          TextButton.icon(
            onPressed: controller.backToLanding,
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
      body: character == null
          ? const _EmptyState(message: 'Escolha uma ficha para continuar.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CharacterCard(character: character, masterMode: false),
                if (controller.activeCombat?.active == true) ...[
                  const SizedBox(height: 16),
                  PlayerCombatSummary(combat: controller.activeCombat!),
                ],
                if (controller.activeCombat == null ||
                    controller.activeCombat?.active == false) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _showCharacterForm(context, existing: character),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar ficha fora de combate'),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Poderes e magias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final power in character.powers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PowerCard(character: character, power: power),
                  ),
                const SizedBox(height: 16),
                Text('Itens', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                for (final item in character.inventory)
                  Card(
                    child: ListTile(
                      title: Text('${item.name} x${item.quantity}'),
                      subtitle: Text(item.description),
                      trailing: item.effectKind == null
                          ? null
                          : const Icon(Icons.front_hand),
                    ),
                  ),
              ],
            ),
    );
  }
}

class PlayerCombatSummary extends StatelessWidget {
  const PlayerCombatSummary({required this.combat, super.key});

  final CombatState combat;

  @override
  Widget build(BuildContext context) {
    final visible = combat.participants.where((participant) {
      if (participant.type == ParticipantType.player) return true;
      return participant.statuses.any((status) => status.visibleToPlayer);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Combate - rodada ${combat.round}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        for (final participant in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                title: Text(participant.name),
                subtitle: participant.type == ParticipantType.player
                    ? Text(
                        'Vida ${participant.currentHp}/${participant.maxHp} - Defesa ${participant.defense}',
                      )
                    : Text(_participantTypeLabel(participant.type)),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    for (final status in participant.statuses.where(
                      (status) => status.visibleToPlayer,
                    ))
                      _StatusChip(status: status),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

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
    final controller = context.watch<RpgSessionController>();
    final combatIsActive = controller.activeCombat?.active == true;
    final weapon = controller.equipmentByName(character.mainWeapon);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${character.name} - Nivel ${character.level}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${character.race} ${character.characterClass} - ${character.concept}',
            ),
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
            Text('Atributos: ${_joinStats(character.attributes)}'),
            Text('Pericias: ${_joinStats(character.skills)}'),
            if (masterMode) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _showLevelUpDialog(context, character),
                    icon: const Icon(Icons.trending_up),
                    label: const Text('Subir nivel'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _showCharacterForm(context, existing: character),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar ficha'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _showPowerLibraryDialog(context, character),
                    icon: const Icon(Icons.auto_stories),
                    label: const Text('Poderes/magias'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _showInventoryEditor(context, character),
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Inventario'),
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
                            .togglePowerRequest(character.id, power.id),
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
              FilledButton.tonalIcon(
                onPressed: () => _showInventoryEditor(context, character),
                icon: const Icon(Icons.inventory_2),
                label: const Text('Editar inventario'),
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
    return Card(
      child: ListTile(
        title: Text(power.name),
        subtitle: Text(
          '${power.type} - ${_usageLabel(power.usageLimit)}\n${power.suggestedTest}\n${power.effect}',
        ),
        isThreeLine: true,
        trailing: power.used
            ? const Chip(label: Text('Solicitado/usado'))
            : OutlinedButton(
                onPressed: () => context
                    .read<RpgSessionController>()
                    .togglePowerRequest(character.id, power.id),
                child: const Text('Solicitar'),
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
    return Chip(
      backgroundColor: RpgTheme.parchmentDark.withValues(alpha: 0.34),
      label: Text('$label: $value'),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StatusEntry status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_statusIcon(status.type), size: 16),
      backgroundColor: _statusColor(status.type).withValues(alpha: 0.18),
      side: BorderSide(
        color: _statusColor(status.type).withValues(alpha: 0.72),
      ),
      label: Text(status.name),
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
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}

void _showTableDialog(BuildContext context) {
  final controller = context.read<RpgSessionController>();
  final name = TextEditingController(text: controller.table.name);
  final code = TextEditingController(text: controller.table.code);

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Configurar mesa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nome da mesa'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: code,
            decoration: const InputDecoration(labelText: 'Codigo local'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        OutlinedButton(
          onPressed: () {
            context.read<RpgSessionController>().regenerateTableCode();
            Navigator.of(context).pop();
          },
          child: const Text('Gerar codigo'),
        ),
        FilledButton(
          onPressed: () {
            context.read<RpgSessionController>().updateTable(
              name: name.text,
              code: code.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

void _showTableCodeDialog(BuildContext context) {
  final code = TextEditingController(
    text: context.read<RpgSessionController>().table.code,
  );

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Entrar ou criar mesa'),
      content: TextField(
        controller: code,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Codigo da mesa',
          helperText: 'Exemplo: GURI-1234',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            await context.read<RpgSessionController>().openTableByCode(
              code.text,
            );
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Entrar/criar'),
        ),
      ],
    ),
  );
}

void _showLevelUpDialog(BuildContext context, CharacterSheet character) {
  final controller = context.read<RpgSessionController>();
  if (character.level >= 10) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nivel maximo 10.')));
    return;
  }

  final newLevel = character.level + 1;
  final isMage = _sameOptionName(character.characterClass, 'Mago');
  final spellOptions = isMage
      ? controller.spellLibrary.where((spell) {
          final wantsStrong = newLevel.isOdd;
          return wantsStrong
              ? spell.usageLimit == UsageLimit.combat
              : spell.usageLimit == UsageLimit.free;
        }).toList()
      : <SpellTemplate>[];
  SpellTemplate? selectedSpell = spellOptions.isEmpty
      ? null
      : spellOptions.first;
  final progression = _firstOrNull(
    controller.classProgression,
    (entry) =>
        _sameOptionName(entry.characterClass, character.characterClass) &&
        entry.level == newLevel,
  );

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${character.name} sobe para nivel $newLevel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Classe atual: ${character.characterClass}'),
            const SizedBox(height: 12),
            if (isMage) ...[
              Text(
                newLevel.isOdd
                    ? 'Escolha 1 magia forte.'
                    : 'Escolha 1 nova magia simples.',
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SpellTemplate>(
                initialValue: selectedSpell,
                items: spellOptions
                    .map(
                      (spell) => DropdownMenuItem(
                        value: spell,
                        child: Text(spell.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedSpell = value),
                decoration: const InputDecoration(labelText: 'Magia'),
              ),
            ] else ...[
              Text(progression?.name ?? 'Habilidade preparada'),
              const SizedBox(height: 6),
              Text(
                progression?.description ??
                    'Detalhar conforme a tabela oficial da classe.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.levelUp(
                character.id,
                selectedSpellId: selectedSpell?.id,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar evolucao'),
          ),
        ],
      ),
    ),
  );
}

void _showPowerLibraryDialog(BuildContext context, CharacterSheet character) {
  final controller = context.read<RpgSessionController>();
  var selectedPower = controller.powerLibrary.isEmpty
      ? null
      : controller.powerLibrary.first;
  var selectedSpell = controller.spellLibrary.isEmpty
      ? null
      : controller.spellLibrary.first;
  var selectedRitual = controller.ritualLibrary.isEmpty
      ? null
      : controller.ritualLibrary.first;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Biblioteca de ${character.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar poder',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (controller.powerLibrary.isEmpty)
                const Text('Biblioteca de poderes ainda carregando.')
              else
                DropdownButtonFormField<PowerTemplate>(
                  initialValue: selectedPower,
                  items: controller.powerLibrary
                      .map(
                        (power) => DropdownMenuItem(
                          value: power,
                          child: Text(power.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedPower = value ?? selectedPower),
                  decoration: const InputDecoration(labelText: 'Poder'),
                ),
              const SizedBox(height: 8),
              if (selectedPower != null) Text(selectedPower!.description),
              const Divider(height: 28),
              Text(
                'Adicionar magia',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (controller.spellLibrary.isEmpty)
                const Text('Biblioteca de magias ainda carregando.')
              else
                DropdownButtonFormField<SpellTemplate>(
                  initialValue: selectedSpell,
                  items: controller.spellLibrary
                      .map(
                        (spell) => DropdownMenuItem(
                          value: spell,
                          child: Text('${spell.name} - ${spell.tier}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedSpell = value ?? selectedSpell),
                  decoration: const InputDecoration(labelText: 'Magia'),
                ),
              const SizedBox(height: 8),
              if (selectedSpell != null) Text(selectedSpell!.description),
              const Divider(height: 28),
              Text(
                'Consultar/adicionar ritual',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (controller.ritualLibrary.isEmpty)
                const Text('Biblioteca de rituais ainda carregando.')
              else
                DropdownButtonFormField<RitualTemplate>(
                  initialValue: selectedRitual,
                  items: controller.ritualLibrary
                      .map(
                        (ritual) => DropdownMenuItem(
                          value: ritual,
                          child: Text(ritual.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedRitual = value ?? selectedRitual),
                  decoration: const InputDecoration(labelText: 'Ritual'),
                ),
              if (selectedRitual != null) ...[
                const SizedBox(height: 8),
                Text(selectedRitual!.suggestedRoll),
                Text(selectedRitual!.difficulty),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          OutlinedButton(
            onPressed: selectedPower == null
                ? null
                : () {
                    controller.addPowerToCharacter(
                      character.id,
                      selectedPower!,
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('Adicionar poder'),
          ),
          OutlinedButton(
            onPressed: selectedRitual == null
                ? null
                : () {
                    controller.addRitualToCharacter(
                      character.id,
                      selectedRitual!,
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('Adicionar ritual'),
          ),
          FilledButton(
            onPressed: selectedSpell == null
                ? null
                : () {
                    controller.addSpellToCharacter(
                      character.id,
                      selectedSpell!,
                    );
                    Navigator.of(context).pop();
                  },
            child: const Text('Adicionar magia'),
          ),
        ],
      ),
    ),
  );
}

void _showInventoryEditor(BuildContext context, CharacterSheet character) {
  final addQuantity = TextEditingController(text: '1');
  final initialLibrary = context.read<RpgSessionController>().itemLibrary;
  var selectedTemplate = initialLibrary.isEmpty ? null : initialLibrary.first;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final controller = context.watch<RpgSessionController>();
        final liveCharacter =
            _firstOrNull(
              controller.characters,
              (item) => item.id == character.id,
            ) ??
            character;

        return AlertDialog(
          title: Text('Inventario de ${liveCharacter.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (liveCharacter.inventory.isEmpty)
                  const Text('Inventario vazio.')
                else
                  for (final item in liveCharacter.inventory)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${item.name} x${item.quantity}'),
                      subtitle: Text(item.description),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            tooltip: 'Diminuir',
                            onPressed: () {
                              controller.upsertInventoryItem(
                                liveCharacter.id,
                                item.copyWith(
                                  quantity: (item.quantity - 1)
                                      .clamp(0, 999)
                                      .toInt(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            tooltip: 'Aumentar',
                            onPressed: () {
                              controller.upsertInventoryItem(
                                liveCharacter.id,
                                item.copyWith(
                                  quantity: (item.quantity + 1)
                                      .clamp(0, 999)
                                      .toInt(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            tooltip: 'Remover',
                            onPressed: () => controller.removeInventoryItem(
                              liveCharacter.id,
                              item.id,
                            ),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                const Divider(height: 28),
                Text(
                  'Adicionar da biblioteca',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (controller.itemLibrary.isEmpty)
                  const Text('Biblioteca oficial ainda carregando.')
                else
                  DropdownButtonFormField<ItemTemplate>(
                    initialValue: selectedTemplate,
                    items: controller.itemLibrary
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => selectedTemplate = value ?? selectedTemplate,
                    ),
                    decoration: const InputDecoration(labelText: 'Item'),
                  ),
                TextField(
                  controller: addQuantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: selectedTemplate == null
                      ? null
                      : () => controller.addItemToCharacter(
                          liveCharacter.id,
                          selectedTemplate!,
                          quantity: int.tryParse(addQuantity.text) ?? 1,
                        ),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar item da biblioteca'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    ),
  );
}

void _showValueDialog(
  BuildContext context, {
  required String title,
  required ValueChanged<int> onConfirm,
}) {
  final controller = TextEditingController(text: '0');
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Valor final informado pelo mestre',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            onConfirm(int.tryParse(controller.text) ?? 0);
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}

void _showStatusDialog(BuildContext context, CombatParticipant participant) {
  final name = TextEditingController();
  final description = TextEditingController();
  final duration = TextEditingController();
  var type = 'Narrativo';
  var visibleToPlayer = true;
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Status de ${participant.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (participant.statuses.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Atuais',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 6),
                for (final status in participant.statuses)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(status.name),
                    subtitle: Text(
                      '${status.type}${status.duration == null || status.duration!.isEmpty ? '' : ' - ${status.duration}'}',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        context.read<RpgSessionController>().removeStatus(
                          participant.id,
                          status.id,
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                const Divider(),
              ],
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              DropdownButtonFormField<String>(
                initialValue: type,
                items:
                    [
                          'Condicao',
                          'Bonus',
                          'Penalidade',
                          'Vantagem',
                          'Desvantagem',
                          'Narrativo',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => type = value ?? type),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextField(
                controller: duration,
                decoration: const InputDecoration(
                  labelText: 'Duracao opcional',
                ),
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Descricao'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: visibleToPlayer,
                onChanged: (value) => setState(() => visibleToPlayer = value),
                title: const Text('Visivel para jogador'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RpgSessionController>().addStatus(
                participant.id,
                StatusEntry(
                  id: 'status-${DateTime.now().microsecondsSinceEpoch}',
                  name: name.text.trim().isEmpty ? 'Status' : name.text.trim(),
                  type: type,
                  duration: duration.text.trim(),
                  visibleToPlayer: visibleToPlayer,
                  description: description.text,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    ),
  );
}

void _showMonsterPicker(BuildContext context) {
  final controller = context.read<RpgSessionController>();
  if (controller.monsters.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biblioteca de monstros ainda carregando.')),
    );
    return;
  }
  var selected = controller.monsters.first;
  final quantity = TextEditingController(text: '1');
  final maxHp = TextEditingController(text: '${selected.maxHp}');
  final defense = TextEditingController(text: '${selected.defense}');
  final damage = TextEditingController(text: selected.damage);

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Adicionar monstro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MonsterTemplate>(
              initialValue: selected,
              items: controller.monsters
                  .map(
                    (monster) => DropdownMenuItem(
                      value: monster,
                      child: Text(monster.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                selected = value ?? selected;
                maxHp.text = '${selected.maxHp}';
                defense.text = '${selected.defense}';
                damage.text = selected.damage;
              }),
              decoration: const InputDecoration(labelText: 'Monstro'),
            ),
            TextField(
              controller: quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            TextField(
              controller: maxHp,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Vida por monstro'),
            ),
            TextField(
              controller: defense,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Defesa'),
            ),
            TextField(
              controller: damage,
              decoration: const InputDecoration(labelText: 'Dano sugerido'),
            ),
            const SizedBox(height: 8),
            Text('${selected.attack} - ${selected.instinct}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.addMonsterToCombat(
                selected,
                int.tryParse(quantity.text) ?? 1,
                maxHp: int.tryParse(maxHp.text),
                defense: int.tryParse(defense.text),
                damageSuggestion: damage.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    ),
  );
}

void _showCustomParticipantDialog(BuildContext context) {
  final name = TextEditingController(text: 'NPC improvisado');
  final maxHp = TextEditingController(text: '10');
  final defense = TextEditingController(text: '10');
  final damage = TextEditingController();
  var type = ParticipantType.npcNeutral;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Adicionar NPC ou objeto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              DropdownButtonFormField<ParticipantType>(
                initialValue: type,
                items:
                    [
                          ParticipantType.npcAlly,
                          ParticipantType.npcNeutral,
                          ParticipantType.npcEnemy,
                          ParticipantType.object,
                        ]
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_participantTypeLabel(item)),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => type = value ?? type),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextField(
                controller: maxHp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vida maxima'),
              ),
              TextField(
                controller: defense,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Defesa'),
              ),
              TextField(
                controller: damage,
                decoration: const InputDecoration(
                  labelText: 'Dano sugerido opcional',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RpgSessionController>().addCustomParticipant(
                name: name.text,
                type: type,
                maxHp: int.tryParse(maxHp.text) ?? 10,
                defense: int.tryParse(defense.text) ?? 10,
                damageSuggestion: damage.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    ),
  );
}

void _showParticipantEditDialog(
  BuildContext context,
  CombatParticipant participant,
) {
  final name = TextEditingController(text: participant.name);
  final currentHp = TextEditingController(text: '${participant.currentHp}');
  final maxHp = TextEditingController(text: '${participant.maxHp}');
  final defense = TextEditingController(text: '${participant.defense}');
  final damage = TextEditingController(
    text: participant.damageSuggestion ?? '',
  );
  var type = participant.type;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Editar participante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              DropdownButtonFormField<ParticipantType>(
                initialValue: type,
                items: ParticipantType.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(_participantTypeLabel(item)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => type = value ?? type),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextField(
                controller: currentHp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vida atual'),
              ),
              TextField(
                controller: maxHp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vida maxima'),
              ),
              TextField(
                controller: defense,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Defesa'),
              ),
              TextField(
                controller: damage,
                decoration: const InputDecoration(labelText: 'Dano sugerido'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final editedMaxHp =
                  (int.tryParse(maxHp.text) ?? participant.maxHp)
                      .clamp(1, 999)
                      .toInt();
              final editedCurrentHp =
                  (int.tryParse(currentHp.text) ?? participant.currentHp)
                      .clamp(0, editedMaxHp)
                      .toInt();
              context.read<RpgSessionController>().updateParticipant(
                participant.copyWith(
                  name: name.text.trim().isEmpty
                      ? participant.name
                      : name.text.trim(),
                  type: type,
                  currentHp: editedCurrentHp,
                  maxHp: editedMaxHp,
                  defense: (int.tryParse(defense.text) ?? participant.defense)
                      .clamp(0, 99)
                      .toInt(),
                  damageSuggestion: damage.text.trim(),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ),
  );
}

void _showConsumableDialog(
  BuildContext context,
  CharacterSheet character,
  InventoryItem item,
) {
  final combat = context.read<RpgSessionController>().activeCombat;
  if (combat == null) return;
  final rolled = TextEditingController(text: '0');
  var targetId = combat.participants.first.id;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Role ${item.roll ?? 'valor definido'} fisico. Bonus fixo: +${item.fixedBonus}.',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rolled,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor rolado/informado',
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: targetId,
                items: combat.participants
                    .map(
                      (participant) => DropdownMenuItem(
                        value: participant.id,
                        child: Text(participant.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => targetId = value ?? targetId),
                decoration: const InputDecoration(labelText: 'Alvo'),
              ),
              const SizedBox(height: 8),
              Text(
                'Total aplicado: ${(int.tryParse(rolled.text) ?? 0) + item.fixedBonus}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RpgSessionController>().applyConsumable(
                characterId: character.id,
                itemId: item.id,
                targetParticipantId: targetId,
                rolledValue: int.tryParse(rolled.text) ?? 0,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    ),
  );
}

void _showJoinRequestDialog(BuildContext context) {
  final name = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Solicitar entrada'),
      content: TextField(
        controller: name,
        decoration: const InputDecoration(labelText: 'Seu nome'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            context.read<RpgSessionController>().requestPlayerApproval(
              name.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Enviar'),
        ),
      ],
    ),
  );
}

void _showCharacterForm(BuildContext context, {CharacterSheet? existing}) {
  final controller = context.read<RpgSessionController>();
  final raceOptions = controller.races.map((item) => item.name).toList();
  final classOptions = controller.classes.map((item) => item.name).toList();
  final weaponOptions = controller.weapons.map((item) => item.name).toList();
  final shieldOptions = controller.shields.map((item) => item.name).toList();
  final armorOptions = controller.armors.map((item) => item.name).toList();
  final accessoryOptions = controller.accessories
      .map((item) => item.name)
      .toList();
  final secondaryOptions = [...weaponOptions, ...shieldOptions];
  final name = TextEditingController(text: existing?.name ?? '');
  final concept = TextEditingController(text: existing?.concept ?? '');
  final currentHp = TextEditingController(text: '${existing?.currentHp ?? 10}');
  final coins = TextEditingController(text: '${existing?.coins ?? 5}');
  final attributeControllers = {
    for (final key in _attributeNames)
      key: TextEditingController(text: '${existing?.attributes[key] ?? 0}'),
  };
  final skillControllers = {
    for (final key in _skillNames)
      key: TextEditingController(text: '${existing?.skills[key] ?? 0}'),
  };
  var race = _officialValue(existing?.race, raceOptions, 'Humano');
  var characterClass = _officialValue(
    existing?.characterClass,
    classOptions,
    'Guerreiro',
  );
  var armor = _officialValue(existing?.armor, armorOptions, 'Sem armadura');
  var mainWeapon = _officialValue(
    existing?.mainWeapon,
    weaponOptions,
    weaponOptions.isNotEmpty
        ? weaponOptions.first
        : 'Soco, chute ou arma improvisada leve',
  );
  var secondaryItem = _officialValue(
    existing?.secondaryItem,
    secondaryOptions,
    secondaryOptions.isNotEmpty ? secondaryOptions.first : mainWeapon,
  );
  var accessoryOne = _officialValue(
    existing?.accessories.isNotEmpty == true ? existing!.accessories[0] : null,
    accessoryOptions,
    '',
  );
  var accessoryTwo = _officialValue(
    existing?.accessories.length == 2 ? existing!.accessories[1] : null,
    accessoryOptions,
    '',
  );

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'Criar ficha' : 'Editar ficha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: concept,
                decoration: const InputDecoration(labelText: 'Conceito'),
              ),
              DropdownButtonFormField<String>(
                initialValue: race,
                items: _ensureDropdownOptions(raceOptions, race)
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => race = value ?? race),
                decoration: const InputDecoration(labelText: 'Raca'),
              ),
              DropdownButtonFormField<String>(
                initialValue: characterClass,
                items: _ensureDropdownOptions(classOptions, characterClass)
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => characterClass = value ?? characterClass),
                decoration: const InputDecoration(labelText: 'Classe'),
              ),
              DropdownButtonFormField<String>(
                initialValue: armor,
                items: _ensureDropdownOptions(armorOptions, armor)
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => armor = value ?? armor),
                decoration: const InputDecoration(labelText: 'Armadura'),
              ),
              DropdownButtonFormField<String>(
                initialValue: mainWeapon,
                items: _ensureDropdownOptions(weaponOptions, mainWeapon)
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => mainWeapon = value ?? mainWeapon),
                decoration: const InputDecoration(labelText: 'Arma principal'),
              ),
              DropdownButtonFormField<String>(
                initialValue: secondaryItem,
                items: _ensureDropdownOptions(secondaryOptions, secondaryItem)
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => secondaryItem = value ?? secondaryItem),
                decoration: const InputDecoration(
                  labelText: 'Secundario ou escudo',
                ),
              ),
              TextField(
                controller: currentHp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Vida atual'),
              ),
              TextField(
                controller: coins,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Moedas'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Atributos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in attributeControllers.entries)
                    SizedBox(
                      width: 116,
                      child: TextField(
                        controller: entry.value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: entry.key),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pericias',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in skillControllers.entries)
                    SizedBox(
                      width: 132,
                      child: TextField(
                        controller: entry.value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: entry.key),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: accessoryOne,
                items: ['', ...accessoryOptions]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.isEmpty ? 'Nenhum' : item),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => accessoryOne = value ?? accessoryOne),
                decoration: const InputDecoration(
                  labelText: 'Acessorio especial 1',
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: accessoryTwo,
                items: ['', ...accessoryOptions]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.isEmpty ? 'Nenhum' : item),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => accessoryTwo = value ?? accessoryTwo),
                decoration: const InputDecoration(
                  labelText: 'Acessorio especial 2',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final attributes = _parseStats(attributeControllers);
              final skills = _parseStats(skillControllers);
              final invalidAttribute = _firstInvalidStat(attributes, 6);
              final invalidSkill = _firstInvalidStat(skills, 3);
              if (invalidAttribute != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$invalidAttribute nao pode passar de +6.'),
                  ),
                );
                return;
              }
              if (invalidSkill != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$invalidSkill nao pode passar de +3.'),
                  ),
                );
                return;
              }
              final accessories = [
                accessoryOne.trim(),
                accessoryTwo.trim(),
              ].where((item) => item.isNotEmpty).toList();
              final hasShield = shieldOptions.any(
                (item) => _sameOptionName(item, secondaryItem),
              );
              final maxHp = 10 + (attributes['Vigor'] ?? 0);
              final parsedCurrentHp =
                  (int.tryParse(currentHp.text) ?? existing?.currentHp ?? maxHp)
                      .clamp(0, maxHp)
                      .toInt();
              final character = CharacterSheet(
                id:
                    existing?.id ??
                    'char-${DateTime.now().microsecondsSinceEpoch}',
                name: name.text.trim().isEmpty
                    ? 'Novo personagem'
                    : name.text.trim(),
                race: race,
                characterClass: characterClass,
                level: existing?.level ?? 1,
                concept: concept.text,
                attributes: attributes,
                skills: skills,
                currentHp: parsedCurrentHp,
                armor: armor,
                hasShield: hasShield,
                mainWeapon: mainWeapon,
                secondaryItem: secondaryItem,
                accessories: accessories,
                powers: existing?.powers ?? const [],
                inventory: existing?.inventory ?? const [],
                statuses: existing?.statuses ?? const [],
                coins: (int.tryParse(coins.text) ?? existing?.coins ?? 5)
                    .clamp(0, 999999)
                    .toInt(),
                ownerName: existing?.ownerName,
              );
              if (existing == null) {
                context.read<RpgSessionController>().addCharacter(character);
              } else {
                context.read<RpgSessionController>().updateCharacter(character);
              }
              Navigator.of(context).pop();
            },
            child: Text(existing == null ? 'Criar' : 'Salvar'),
          ),
        ],
      ),
    ),
  );
}

String _joinStats(Map<String, int> values) {
  return values.entries
      .map(
        (entry) => '${entry.key} ${entry.value >= 0 ? '+' : ''}${entry.value}',
      )
      .join(', ');
}

String _officialValue(String? current, List<String> options, String fallback) {
  if (current != null) {
    for (final option in options) {
      if (_sameOptionName(option, current)) return option;
    }
  }
  if (fallback.isNotEmpty) {
    for (final option in options) {
      if (_sameOptionName(option, fallback)) return option;
    }
  }
  if (options.isNotEmpty) return options.first;
  return fallback;
}

List<String> _ensureDropdownOptions(List<String> options, String selected) {
  if (options.contains(selected)) return options;
  if (selected.isEmpty) return options;
  return [selected, ...options];
}

bool _sameOptionName(String left, String right) {
  return _canonicalOptionName(left) == _canonicalOptionName(right);
}

String _canonicalOptionName(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ã', 'a')
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

const _attributeNames = [
  'Forca',
  'Agilidade',
  'Intelecto',
  'Presenca',
  'Vigor',
];

const _skillNames = [
  'Atletismo',
  'Furtividade',
  'Percepcao',
  'Natureza',
  'Conhecimento',
  'Influencia',
  'Oficio',
  'Combate',
  'Misticismo',
];

Map<String, int> _parseStats(Map<String, TextEditingController> controllers) {
  return {
    for (final entry in controllers.entries)
      entry.key: int.tryParse(entry.value.text) ?? 0,
  };
}

String? _firstInvalidStat(Map<String, int> values, int max) {
  for (final entry in values.entries) {
    if (entry.value > max) return entry.key;
  }
  return null;
}

T? _firstOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}

Color _hpColor(double percent) {
  if (percent <= 0.25) return RpgTheme.danger;
  if (percent <= 0.5) return RpgTheme.ochre;
  return RpgTheme.moss;
}

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
    UsageLimit.session => '1x por sessao',
    UsageLimit.longRest => '1x por descanso longo',
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
