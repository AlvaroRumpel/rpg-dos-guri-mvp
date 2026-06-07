part of '../shell/session_shell.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  _PlayerTab tab = _PlayerTab.sheet;
  bool showSecondaryWeapon = false;

  @override
  Widget build(BuildContext context) {
    final character = context.select<RpgSessionController, CharacterSheet?>(
      (controller) => controller.selectedCharacter,
    );
    final combat = context.select<RpgSessionController, CombatState?>(
      (controller) => controller.activeCombat,
    );
    final inCombat = combat?.active == true;

    return Scaffold(
      body: RpgStage(
        child: SafeArea(
          child: character == null
              ? const Center(
                  child: _EmptyState(
                    message: 'Escolha uma ficha para continuar.',
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 154),
                          children: [
                            if (inCombat)
                              _PlayerCombatBanner(round: combat!.round),
                            _PlayerHero(
                              character: character,
                              inCombat: inCombat,
                              showSecondaryWeapon: showSecondaryWeapon,
                              onToggleWeapon: () => setState(
                                () =>
                                    showSecondaryWeapon = !showSecondaryWeapon,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RpgTabs<_PlayerTab>(
                              dense: true,
                              value: tab,
                              onChanged: (value) {
                                RpgPerformanceTrace.mark('player.tab_change', {
                                  'from': tab.name,
                                  'to': value.name,
                                });
                                setState(() => tab = value);
                              },
                              tabs: [
                                const RpgTabItem(
                                  value: _PlayerTab.sheet,
                                  label: 'Ficha',
                                  icon: Icons.menu_book,
                                ),
                                RpgTabItem(
                                  value: _PlayerTab.powers,
                                  label: 'Poderes',
                                  icon: Icons.auto_stories,
                                  badge: character.powers.length,
                                ),
                                RpgTabItem(
                                  value: _PlayerTab.items,
                                  label: 'Itens',
                                  icon: Icons.inventory_2,
                                  badge: character.inventory.length,
                                ),
                                RpgTabItem(
                                  value: _PlayerTab.status,
                                  label: 'Status',
                                  icon: Icons.label,
                                  badge: character.statuses.length,
                                ),
                                RpgTabItem(
                                  value: _PlayerTab.notes,
                                  label: 'Notas',
                                  icon: Icons.sticky_note_2,
                                  badge: character.notes.length,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (tab == _PlayerTab.sheet) ...[
                              _PlayerSheetTab(character: character),
                              if (inCombat) ...[
                                const SizedBox(height: 16),
                                PlayerCombatSummary(combat: combat!),
                              ],
                            ],
                            if (tab == _PlayerTab.powers)
                              for (final power in character.powers)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: PowerCard(
                                    character: character,
                                    power: power,
                                  ),
                                ),
                            if (tab == _PlayerTab.items)
                              _PlayerItemsTab(character: character),
                            if (tab == _PlayerTab.status)
                              _PlayerStatusTab(character: character),
                            if (tab == _PlayerTab.notes)
                              _PlayerNotesTab(character: character),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _PlayerActionBar(
                        inCombat: inCombat,
                        onEdit: () =>
                            _showCharacterForm(context, existing: character),
                        onRequestUse: () =>
                            setState(() => tab = _PlayerTab.powers),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PlayerHero extends StatelessWidget {
  const _PlayerHero({
    required this.character,
    required this.inCombat,
    required this.showSecondaryWeapon,
    required this.onToggleWeapon,
  });

  final CharacterSheet character;
  final bool inCombat;
  final bool showSecondaryWeapon;
  final VoidCallback onToggleWeapon;

  @override
  Widget build(BuildContext context) {
    final primary = context.select<RpgSessionController, EquipmentTemplate?>(
      (controller) => controller.equipmentByName(character.mainWeapon),
    );
    final secondary = context.select<RpgSessionController, EquipmentTemplate?>(
      (controller) => controller.equipmentByName(character.secondaryItem),
    );
    final selectedEquipment = showSecondaryWeapon && secondary != null
        ? secondary
        : primary;
    final selectedName = showSecondaryWeapon && secondary != null
        ? character.secondaryItem
        : character.mainWeapon;
    final selectedIsShield =
        selectedEquipment?.category == EquipmentCategory.shield;
    final selectedValue = selectedIsShield
        ? '+${selectedEquipment?.defenseBonus ?? 0}'
        : selectedEquipment?.damage ?? '-';
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RpgTheme.lineGold)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: RpgButton(
              label: 'Sair',
              icon: Icons.logout,
              small: true,
              onPressed: context.read<RpgSessionController>().backToLanding,
            ),
          ),
          RpgPortrait(
            label: 'NV ${character.level}',
            sigil: character.characterClass,
            size: 108,
            color: RpgTheme.lineGold,
            showLabel: true,
          ),
          const SizedBox(height: 18),
          Text(
            '${character.race} - ${character.characterClass}'.toUpperCase(),
            textAlign: TextAlign.center,
            style: RpgTextStyles.eyebrow(
              color: RpgColors.goldDeep,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            character.name,
            textAlign: TextAlign.center,
            style: RpgTextStyles.display(
              size: 20,
              color: RpgTheme.goldBright,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 10),
          const RpgOrnament(width: 180),
          const SizedBox(height: 14),
          RpgHpBar(
            current: character.currentHp,
            max: character.maxHp,
            height: 16,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: RpgSpacing.sm,
            runSpacing: RpgSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: RpgButton(
                  onPressed: onToggleWeapon,
                  icon: Icons.swap_horiz,
                  label: showSecondaryWeapon ? 'Secundária' : 'Principal',
                  small: true,
                  expand: true,
                ),
              ),
              SizedBox(
                width: 150,
                child: RpgMetaPill(
                  icon: Icons.shield,
                  label: 'Defesa',
                  value: '${character.defense}',
                ),
              ),
              SizedBox(
                width: 150,
                child: RpgMetaPill(
                  icon: selectedIsShield
                      ? Icons.security
                      : Icons.local_fire_department,
                  label: selectedIsShield ? 'Bônus escudo' : 'Dano',
                  value: selectedValue,
                ),
              ),
              SizedBox(
                width: 150,
                child: RpgMetaPill(
                  icon: Icons.gavel,
                  label: 'Equipamento',
                  value: selectedName,
                ),
              ),
              SizedBox(
                width: 150,
                child: RpgMetaPill(
                  icon: Icons.monetization_on,
                  label: 'Moedas',
                  value: '${character.coins}',
                ),
              ),
            ],
          ),
          if (inCombat) ...[
            const SizedBox(height: 10),
            Text(
              'Ficha bloqueada durante combate',
              style: RpgTextStyles.eyebrow(size: 9, color: RpgTheme.danger),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerCombatBanner extends StatelessWidget {
  const _PlayerCombatBanner({required this.round});

  final int round;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: RpgSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: RpgSpacing.md,
        vertical: RpgSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: RpgTheme.blood.withValues(alpha: 0.22),
        border: const Border(bottom: BorderSide(color: RpgTheme.blood)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: RpgTheme.danger,
            size: 16,
          ),
          const SizedBox(width: RpgSpacing.sm),
          Expanded(
            child: Text(
              'Combate em curso - rodada $round',
              style: RpgTextStyles.button(size: 10, color: RpgTheme.danger),
            ),
          ),
          const RpgStateLamp(state: DefeatedState.active),
        ],
      ),
    );
  }
}

class _PlayerActionBar extends StatelessWidget {
  const _PlayerActionBar({
    required this.inCombat,
    required this.onEdit,
    required this.onRequestUse,
  });

  final bool inCombat;
  final VoidCallback onEdit;
  final VoidCallback onRequestUse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RpgTheme.bgDeep.withValues(alpha: 0),
            RpgTheme.bgDeep.withValues(alpha: 0.92),
            RpgTheme.bgDeep,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              child: RpgPanel(
                raised: true,
                doubleBorder: true,
                padding: const EdgeInsets.all(RpgSpacing.sm),
                child: inCombat
                    ? Row(
                        children: [
                          Expanded(
                            child: RpgButton(
                              label: 'Ficha bloqueada',
                              icon: Icons.visibility_off,
                              onPressed: null,
                              expand: true,
                            ),
                          ),
                          const SizedBox(width: RpgSpacing.sm),
                          Expanded(
                            child: RpgButton(
                              label: 'Pedir uso',
                              icon: Icons.back_hand,
                              variant: RpgButtonVariant.primary,
                              expand: true,
                              onPressed: onRequestUse,
                            ),
                          ),
                        ],
                      )
                    : RpgButton(
                        label: 'Editar ficha',
                        icon: Icons.menu_book,
                        variant: RpgButtonVariant.primary,
                        expand: true,
                        onPressed: onEdit,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerSheetTab extends StatelessWidget {
  const _PlayerSheetTab({required this.character});

  final CharacterSheet character;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RpgSectionTitle(title: 'Atributos', icon: Icons.shield),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          childAspectRatio: 0.86,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            for (final stat in character.attributes.entries)
              RpgStatBadge(
                label: stat.key.substring(0, stat.key.length.clamp(0, 4)),
                value: stat.value,
                accent: stat.value >= 3,
              ),
          ],
        ),
        const SizedBox(height: 14),
        const RpgSectionTitle(title: 'Perícias', icon: Icons.explore),
        const SizedBox(height: 8),
        RpgPanel(
          inset: true,
          child: Column(
            children: [
              for (final skill in character.skills.entries)
                _StatRow(label: skill.key, value: '+${skill.value}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerItemsTab extends StatelessWidget {
  const _PlayerItemsTab({required this.character});

  final CharacterSheet character;

  @override
  Widget build(BuildContext context) {
    if (character.inventory.isEmpty) {
      return const _EmptyState(message: 'Nenhum item registrado.');
    }
    return Column(
      children: [
        for (final item in character.inventory)
          RpgPanel(
            margin: const EdgeInsets.only(bottom: 8),
            inset: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.effectKind == null ? Icons.backpack : Icons.local_drink,
                  color: item.effectKind == null
                      ? RpgTheme.steel
                      : RpgTheme.ochre,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.name} x${item.quantity}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: RpgTheme.mutedInk,
                          fontSize: 12,
                        ),
                      ),
                      if (item.roll != null) ...[
                        const SizedBox(height: 8),
                        RpgInfoRow(
                          label: 'Rolagem',
                          value: '${item.roll} + ${item.fixedBonus}',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlayerStatusTab extends StatelessWidget {
  const _PlayerStatusTab({required this.character});

  final CharacterSheet character;

  @override
  Widget build(BuildContext context) {
    if (character.statuses.isEmpty) {
      return const _EmptyState(message: 'Nenhum status ativo.');
    }
    return Column(
      children: [
        for (final status in character.statuses)
          RpgPanel(
            margin: const EdgeInsets.only(bottom: 8),
            inset: true,
            child: Row(
              children: [
                _StatusChip(status: status),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status.description,
                    style: const TextStyle(
                      color: RpgTheme.mutedInk,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PlayerNotesTab extends StatefulWidget {
  const _PlayerNotesTab({required this.character});

  final CharacterSheet character;

  @override
  State<_PlayerNotesTab> createState() => _PlayerNotesTabState();
}

class _PlayerNotesTabState extends State<_PlayerNotesTab> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';
  List<CampaignNote>? _cachedSource;
  String? _cachedQuery;
  List<CampaignNote> _cachedNotes = const [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RpgSessionController>();
    final notes = _filteredNotes(widget.character.notes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: RpgSearchField(
                controller: _searchController,
                hintText: 'Buscar nas suas notas',
                onChanged: (value) => setState(() => query = value),
              ),
            ),
            const SizedBox(width: 8),
            RpgButton(
              onPressed: () =>
                  _showCharacterNoteEditor(context, widget.character),
              icon: Icons.add,
              label: 'Nota',
              variant: RpgButtonVariant.primary,
              small: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          const _EmptyState(message: 'Nenhuma nota encontrada.')
        else
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CampaignNoteCard(
                note: note,
                linkMentions: false,
                onEdit: () => _showCharacterNoteEditor(
                  context,
                  widget.character,
                  existing: note,
                ),
                onDelete: () => controller.deleteCharacterNote(
                  widget.character.id,
                  note.id,
                ),
              ),
            ),
      ],
    );
  }

  List<CampaignNote> _filteredNotes(List<CampaignNote> source) {
    if (identical(_cachedSource, source) && _cachedQuery == query) {
      return _cachedNotes;
    }
    final notes = source.where((note) => _noteMatches(note, query)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _cachedSource = source;
    _cachedQuery = query;
    _cachedNotes = notes;
    return notes;
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
        RpgSectionTitle(
          title: 'Combate',
          subtitle: 'rodada ${combat.round}',
          icon: Icons.local_fire_department,
          accent: RpgTheme.danger,
        ),
        const SizedBox(height: 8),
        for (final participant in visible)
          RpgPanel(
            margin: const EdgeInsets.only(bottom: 8),
            inset: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        participant.type == ParticipantType.player
                            ? 'Vida ${participant.currentHp}/${participant.maxHp} - Defesa ${participant.defense}'
                            : _participantTypeLabel(participant.type),
                        style: const TextStyle(
                          color: RpgTheme.mutedInk,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final status in participant.statuses.where(
                      (status) => status.visibleToPlayer,
                    ))
                      _StatusChip(status: status),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
