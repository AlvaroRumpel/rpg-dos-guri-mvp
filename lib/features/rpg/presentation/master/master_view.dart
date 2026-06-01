part of '../shell/session_shell.dart';

class MasterView extends StatefulWidget {
  const MasterView({super.key});

  @override
  State<MasterView> createState() => _MasterViewState();
}

class _MasterViewState extends State<MasterView> {
  _MasterScene scene = _MasterScene.table;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RpgSessionController>();
    final combat = controller.activeCombat;

    return Scaffold(
      body: RpgStage(
        child: SafeArea(
          child: Column(
            children: [
              _MasterTopBar(controller: controller, combat: combat),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 980;
                    final main = _MasterSceneBody(
                      scene: scene,
                      controller: controller,
                      combat: combat,
                      wide: wide,
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          _MasterActionStrip(
                            controller: controller,
                            combat: combat,
                          ),
                          RpgTabs<_MasterScene>(
                            dense: true,
                            value: scene,
                            onChanged: (value) => setState(() => scene = value),
                            tabs: _masterTabs(controller),
                          ),
                          Expanded(child: main),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 270,
                          child: _MasterSideRail(
                            controller: controller,
                            combat: combat,
                            scene: scene,
                            onSceneChanged: (value) =>
                                setState(() => scene = value),
                          ),
                        ),
                        Expanded(child: main),
                        SizedBox(
                          width: 320,
                          child: _MasterRightRail(controller: controller),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterTopBar extends StatelessWidget {
  const _MasterTopBar({required this.controller, required this.combat});

  final RpgSessionController controller;
  final CombatState? combat;

  @override
  Widget build(BuildContext context) {
    final active = combat?.active == true;
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RpgTheme.bgBase, RpgTheme.bgDeep],
        ),
        border: Border(bottom: BorderSide(color: RpgColors.goldDeep)),
      ),
      child: Row(
        children: [
          const RpgCrest(size: 30, compact: true),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RPG dos Guri',
                overflow: TextOverflow.ellipsis,
                style: RpgTextStyles.display(
                  size: 12,
                  color: RpgTheme.goldBright,
                  weight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Painel do Mestre',
                style: RpgTextStyles.mono(color: RpgTheme.inkDim, size: 10),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Container(width: 1, height: 32, color: RpgTheme.line),
          const SizedBox(width: 18),
          RpgPanel(
            inset: true,
            borderColor: RpgColors.goldDeep,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MESA', style: RpgTextStyles.eyebrow(size: 9)),
                const SizedBox(width: 8),
                Text(
                  controller.table.code,
                  style: RpgTextStyles.mono(
                    color: RpgTheme.goldBright,
                    size: 13,
                    weight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              controller.table.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 11),
            ),
          ),
          if (active) ...[
            const Icon(Icons.local_fire_department, color: RpgTheme.danger),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'COMBATE ATIVO',
                  style: RpgTextStyles.eyebrow(
                    size: 9,
                    color: RpgTheme.danger,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Rodada ${combat!.round}',
                  style: const TextStyle(
                    color: RpgTheme.mutedInk,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
          ],
          RpgButton(
            label: 'Sair',
            icon: Icons.logout,
            small: true,
            variant: RpgButtonVariant.ghost,
            onPressed: controller.backToLanding,
          ),
        ],
      ),
    );
  }
}

class _MasterActionStrip extends StatelessWidget {
  const _MasterActionStrip({required this.controller, required this.combat});

  final RpgSessionController controller;
  final CombatState? combat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: RpgTheme.bgBase,
        border: Border(bottom: BorderSide(color: RpgTheme.line)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _masterActions(context, controller, combat)
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: child,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _MasterSideRail extends StatelessWidget {
  const _MasterSideRail({
    required this.controller,
    required this.combat,
    required this.scene,
    required this.onSceneChanged,
  });

  final RpgSessionController controller;
  final CombatState? combat;
  final _MasterScene scene;
  final ValueChanged<_MasterScene> onSceneChanged;

  @override
  Widget build(BuildContext context) {
    final activeCombat = combat?.active == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: RpgTheme.bgBase,
        border: Border(right: BorderSide(color: RpgTheme.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final tab in _masterTabs(controller))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _MasterNavButton(
                tab: tab,
                active: scene == tab.value,
                onPressed: () => onSceneChanged(tab.value),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: RpgHairline(gold: true),
          ),
          if (activeCombat)
            RpgPanel(
              ornate: true,
              borderColor: RpgTheme.danger,
              danger: true,
              child: Column(
                children: [
                  Text(
                    'RODADA',
                    style: RpgTextStyles.eyebrow(color: RpgTheme.danger),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    combat!.round.toString().padLeft(2, '0'),
                    style: RpgTextStyles.mono(
                      size: 42,
                      color: RpgTheme.goldBright,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RpgButton(
                    label: 'Avancar rodada',
                    icon: Icons.chevron_right,
                    small: true,
                    expand: true,
                    onPressed: () => controller.changeRound(1),
                  ),
                ],
              ),
            )
          else
            RpgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ESTADO DA MESA', style: RpgTextStyles.eyebrow()),
                  const SizedBox(height: 10),
                  _StatRow(
                    label: 'Personagens',
                    value: '${controller.activeCharacters.length}',
                  ),
                  _StatRow(
                    label: 'Pendentes',
                    value: '${controller.pendingPlayerNames.length}',
                  ),
                  _StatRow(
                    label: 'Pedidos',
                    value: '${controller.powerUseRequests.length}',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          RpgPanel(
            child: Column(
              children: [
                const RpgPanelHeader(
                  title: 'Ações rápidas',
                  icon: Icons.bolt,
                  dense: true,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ..._masterActions(context, controller, combat).map(
                        (button) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: button,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterRightRail extends StatelessWidget {
  const _MasterRightRail({required this.controller});

  final RpgSessionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: RpgTheme.bgBase,
        border: Border(left: BorderSide(color: RpgTheme.line)),
      ),
      child: ListView(
        children: [
          const RpgSectionTitle(title: 'Pendentes', icon: Icons.person_add),
          const SizedBox(height: 10),
          if (controller.pendingPlayerNames.isEmpty)
            const Text(
              'Nenhum pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: RpgTheme.inkDim),
            )
          else
            for (final playerName in controller.pendingPlayerNames)
              RpgPanel(
                margin: const EdgeInsets.only(bottom: 8),
                borderColor: RpgTheme.ochre,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Uma ficha inicial sera criada ao aprovar.',
                      style: TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    RpgButton(
                      onPressed: () => controller.approvePlayer(playerName),
                      label: 'Aprovar',
                      icon: Icons.check,
                      small: true,
                      expand: true,
                      variant: RpgButtonVariant.primary,
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 18),
          _PowerRequestsPanel(controller: controller),
          const SizedBox(height: 18),
          const RpgSectionTitle(title: 'Cronica', icon: Icons.history_edu),
          const SizedBox(height: 10),
          for (final item in controller.actionLog.take(10))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                item,
                style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _MasterNavButton extends StatelessWidget {
  const _MasterNavButton({
    required this.tab,
    required this.active,
    required this.onPressed,
  });

  final RpgTabItem<_MasterScene> tab;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(RpgRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? RpgTheme.lineGold.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: active ? RpgTheme.lineGold : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(RpgRadius.md),
          ),
          child: Row(
            children: [
              if (tab.icon != null) ...[
                Icon(
                  tab.icon,
                  size: 15,
                  color: active ? RpgTheme.goldBright : RpgTheme.mutedInk,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  tab.label,
                  overflow: TextOverflow.ellipsis,
                  style: RpgTextStyles.button(
                    size: 10.5,
                    color: active ? RpgTheme.goldBright : RpgTheme.mutedInk,
                  ),
                ),
              ),
              if (tab.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: active ? RpgColors.goldDeep : RpgTheme.bgInset,
                    borderRadius: BorderRadius.circular(RpgRadius.sm),
                  ),
                  child: Text(
                    '${tab.badge}',
                    style: RpgTextStyles.mono(
                      size: 10,
                      color: active ? RpgTheme.bgDeep : RpgTheme.ink,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<RpgTabItem<_MasterScene>> _masterTabs(RpgSessionController controller) {
  return [
    const RpgTabItem(
      value: _MasterScene.table,
      label: 'Mesa/Combate',
      icon: Icons.shield,
    ),
    RpgTabItem(
      value: _MasterScene.roster,
      label: 'Companhia',
      icon: Icons.groups,
      badge: controller.activeCharacters.length,
    ),
    const RpgTabItem(
      value: _MasterScene.library,
      label: 'Biblioteca',
      icon: Icons.auto_stories,
    ),
    RpgTabItem(
      value: _MasterScene.log,
      label: 'Log',
      icon: Icons.history_edu,
      badge: controller.actionLog.length,
    ),
  ];
}

List<Widget> _masterActions(
  BuildContext context,
  RpgSessionController controller,
  CombatState? combat,
) {
  return [
    RpgButton(
      onPressed: controller.startCombat,
      icon: Icons.shield,
      label: combat == null || !combat.active ? 'Iniciar combate' : 'Reiniciar',
      variant: RpgButtonVariant.primary,
      small: true,
    ),
    if (combat != null && combat.active)
      RpgButton(
        onPressed: controller.finishCombat,
        icon: Icons.flag,
        label: 'Finalizar',
        variant: RpgButtonVariant.danger,
        small: true,
      ),
    RpgButton(
      onPressed: () => _showCharacterForm(context),
      icon: Icons.person_add,
      label: 'Nova ficha',
      variant: RpgButtonVariant.ghost,
      small: true,
    ),
    RpgButton(
      onPressed: () => _showTableDialog(context),
      icon: Icons.settings,
      label: 'Mesa',
      variant: RpgButtonVariant.ghost,
      small: true,
    ),
    RpgButton(
      onPressed: controller.resetSessionUses,
      icon: Icons.refresh,
      label: 'Reset sessão',
      variant: RpgButtonVariant.ghost,
      small: true,
    ),
    RpgButton(
      onPressed: controller.resetLongRestUses,
      icon: Icons.bedtime,
      label: 'Descanso longo',
      variant: RpgButtonVariant.ghost,
      small: true,
    ),
  ];
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: RpgTheme.mutedInk)),
          Text(
            value,
            style: const TextStyle(
              color: RpgTheme.inkBright,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterSceneBody extends StatelessWidget {
  const _MasterSceneBody({
    required this.scene,
    required this.controller,
    required this.combat,
    required this.wide,
  });

  final _MasterScene scene;
  final RpgSessionController controller;
  final CombatState? combat;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return switch (scene) {
      _MasterScene.table => _TableCombatScene(combat: combat),
      _MasterScene.roster => _RosterScene(controller: controller),
      _MasterScene.library => _LibraryScene(controller: controller),
      _MasterScene.log => _LogScene(controller: controller),
    };
  }
}

class _TableCombatScene extends StatelessWidget {
  const _TableCombatScene({required this.combat});

  final CombatState? combat;

  @override
  Widget build(BuildContext context) {
    final inactiveCombat = combat != null && combat!.active == false;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        if (combat == null)
          Column(
            children: [
              _PowerRequestsPanel(
                controller: context.watch<RpgSessionController>(),
              ),
              const SizedBox(height: 12),
              _NoCombatState(
                onStart: context.read<RpgSessionController>().startCombat,
              ),
            ],
          )
        else if (inactiveCombat)
          Column(
            children: [
              _PowerRequestsPanel(
                controller: context.watch<RpgSessionController>(),
              ),
              const SizedBox(height: 12),
              _PostCombatScene(combat: combat!),
            ],
          )
        else
          Column(
            children: [
              _PowerRequestsPanel(
                controller: context.watch<RpgSessionController>(),
              ),
              const SizedBox(height: 12),
              CombatPanel(combat: combat!),
            ],
          ),
      ],
    );
  }
}

class _PowerRequestsPanel extends StatelessWidget {
  const _PowerRequestsPanel({required this.controller});

  final RpgSessionController controller;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      inset: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RpgPanelHeader(title: 'Pedidos de poder', icon: Icons.bolt),
          Padding(
            padding: const EdgeInsets.all(10),
            child: controller.powerUseRequests.isEmpty
                ? const Text(
                    'Nenhum pedido de poder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: RpgTheme.inkDim),
                  )
                : Column(
                    children: [
                      for (final request in controller.powerUseRequests)
                        RpgPanel(
                          margin: const EdgeInsets.only(bottom: 8),
                          borderColor: RpgTheme.lineGold,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.powerName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${request.characterName} - ${_usageLabel(request.usageLimit)}',
                                style: const TextStyle(
                                  color: RpgTheme.mutedInk,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  RpgButton(
                                    onPressed: () =>
                                        controller.approvePowerUse(request.id),
                                    label: 'Aprovar',
                                    icon: Icons.check,
                                    small: true,
                                    variant: RpgButtonVariant.primary,
                                  ),
                                  RpgButton(
                                    onPressed: () => controller
                                        .discardPowerUseRequest(request.id),
                                    label: 'Descartar',
                                    icon: Icons.close,
                                    small: true,
                                    variant: RpgButtonVariant.ghost,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RosterScene extends StatelessWidget {
  const _RosterScene({required this.controller});

  final RpgSessionController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Row(
          children: [
            const Expanded(
              child: RpgSectionTitle(
                title: 'Companhia',
                subtitle: 'fichas aprovadas',
                icon: Icons.groups,
              ),
            ),
            RpgButton(
              onPressed: () => _showCharacterForm(context),
              icon: Icons.person_add,
              label: 'Nova ficha',
              variant: RpgButtonVariant.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 2
                : constraints.maxWidth > 620
                ? 2
                : 1;
            const spacing = 12.0;
            final width =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final character in controller.activeCharacters)
                  SizedBox(
                    width: width,
                    child: CharacterCard(
                      character: character,
                      masterMode: true,
                    ),
                  ),
              ],
            );
          },
        ),
        if (controller.archivedCharacters.isNotEmpty) ...[
          const SizedBox(height: 20),
          const RpgSectionTitle(
            title: 'Arquivo',
            subtitle: 'fichas ocultas da mesa',
            icon: Icons.archive,
          ),
          const SizedBox(height: 12),
          for (final character in controller.archivedCharacters)
            RpgPanel(
              margin: const EdgeInsets.only(bottom: 8),
              inset: true,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      character.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  RpgButton(
                    onPressed: () => controller.restoreCharacter(character.id),
                    icon: Icons.unarchive,
                    label: 'Restaurar',
                    small: true,
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _LogScene extends StatelessWidget {
  const _LogScene({required this.controller});

  final RpgSessionController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const RpgSectionTitle(title: 'Log completo', icon: Icons.history_edu),
        const SizedBox(height: 12),
        RpgPanel(
          padding: const EdgeInsets.all(18),
          child: controller.actionLog.isEmpty
              ? const Text('Sem eventos ainda.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in controller.actionLog)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(item),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PostCombatScene extends StatelessWidget {
  const _PostCombatScene({required this.combat});

  final CombatState combat;

  @override
  Widget build(BuildContext context) {
    final players = combat.participants
        .where((item) => item.type == ParticipantType.player)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RpgOrnament(width: 260, color: RpgTheme.gold),
        const SizedBox(height: 12),
        Text(
          'Encontro encerrado'.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 18),
        RpgPanel(
          ornate: true,
          borderColor: RpgTheme.lineGold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RpgPanelHeader(
                title: 'Estado da Companhia',
                icon: Icons.favorite,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (final player in players)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            RpgPortrait(
                              label: player.name,
                              size: 36,
                              icon: Icons.shield,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  RpgHpBar(
                                    current: player.currentHp,
                                    max: player.maxHp,
                                    height: 6,
                                    showLabel: false,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _StateChip(state: player.defeatedState),
                          ],
                        ),
                      ),
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

class _LibraryScene extends StatefulWidget {
  const _LibraryScene({required this.controller});

  final RpgSessionController controller;

  @override
  State<_LibraryScene> createState() => _LibrarySceneState();
}

enum _LibraryTab {
  races,
  classes,
  progression,
  grimoire,
  powers,
  equipment,
  items,
  kits,
  monsters,
}

class _LibrarySceneState extends State<_LibraryScene> {
  _LibraryTab tab = _LibraryTab.monsters;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String query = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final tabs = [
      RpgTabItem(
        value: _LibraryTab.races,
        label: 'Raças',
        badge: controller.races.length,
      ),
      RpgTabItem(
        value: _LibraryTab.classes,
        label: 'Classes',
        badge: controller.classes.length,
      ),
      RpgTabItem(
        value: _LibraryTab.progression,
        label: 'Progressão',
        badge: controller.classProgression.length,
      ),
      RpgTabItem(
        value: _LibraryTab.grimoire,
        label: 'Grimório',
        badge: controller.spellLibrary.length + controller.ritualLibrary.length,
      ),
      RpgTabItem(
        value: _LibraryTab.powers,
        label: 'Poderes',
        badge: controller.powerLibrary.length,
      ),
      RpgTabItem(
        value: _LibraryTab.equipment,
        label: 'Equipamentos',
        badge: controller.equipmentLibrary.length,
      ),
      RpgTabItem(
        value: _LibraryTab.items,
        label: 'Itens',
        badge: controller.itemLibrary.length,
      ),
      RpgTabItem(
        value: _LibraryTab.kits,
        label: 'Kits',
        badge: controller.starterKits.length,
      ),
      RpgTabItem(
        value: _LibraryTab.monsters,
        label: 'Monstros',
        badge: controller.monsters.length,
      ),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: RpgTheme.line)),
          ),
          child: Column(
            children: [
              const RpgSectionTitle(
                title: 'Biblioteca do Concílio',
                subtitle: 'fonte oficial local',
                icon: Icons.auto_stories,
              ),
              const SizedBox(height: 8),
              RpgTabs<_LibraryTab>(
                dense: true,
                value: tab,
                onChanged: (value) => setState(() {
                  tab = value;
                  query = '';
                  _searchController.clear();
                }),
                tabs: tabs,
              ),
              const SizedBox(height: 12),
              RpgSearchField(
                controller: _searchController,
                hintText: 'Buscar nesta aba',
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 180),
                    () {
                      if (mounted) setState(() => query = value);
                    },
                  );
                },
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        Expanded(child: _libraryContent(controller)),
      ],
    );
  }

  Widget _libraryContent(RpgSessionController controller) {
    final normalizedQuery = query.trim().toLowerCase();
    bool matches(Iterable<String?> values) {
      if (normalizedQuery.isEmpty) return true;
      return values.whereType<String>().any(
        (value) => value.toLowerCase().contains(normalizedQuery),
      );
    }

    final cards = switch (tab) {
      _LibraryTab.races => [
        for (final race in controller.races)
          if (matches([
            race.name,
            race.identity,
            race.powerName,
            race.powerEffect,
            race.notes,
          ]))
            _LibraryCard(
              icon: Icons.workspace_premium,
              title: race.name,
              subtitle: race.identity,
              chips: [
                _LibraryChip('origem', race.origin ?? 'Raça'),
                _LibraryChip('limite', _usageLimitLabel(race.usageLimit)),
                if (race.actionCost != null)
                  _LibraryChip('uso', race.actionCost!),
              ],
              details: [
                race.powerName,
                race.powerDescription,
                race.powerEffect,
                ?race.notes,
                ?race.source,
              ],
            ),
      ],
      _LibraryTab.classes => [
        for (final klass in controller.classes)
          if (matches([
            klass.name,
            klass.role,
            klass.initialPowerName,
            ...klass.skills,
            klass.description,
          ]))
            _LibraryCard(
              icon: Icons.shield,
              title: klass.name,
              subtitle: klass.role,
              chips: [
                _LibraryChip('perícias', klass.skills.join(', ')),
                _LibraryChip('inicial', klass.initialPowerName),
              ],
              details: [?klass.description, ?klass.notes, ?klass.source],
            ),
      ],
      _LibraryTab.progression => [
        for (final entry in controller.classProgression)
          if (matches([
            entry.characterClass,
            entry.name,
            entry.description,
            entry.notes,
          ]))
            _LibraryCard(
              icon: Icons.trending_up,
              title: entry.name,
              subtitle: '${entry.characterClass} - nível ${entry.level}',
              chips: [
                _LibraryChip('limite', _usageLimitLabel(entry.usageLimit)),
                if (entry.actionCost != null)
                  _LibraryChip('uso', entry.actionCost!),
                if (entry.roll != null) _LibraryChip('rolagem', entry.roll!),
              ],
              details: [entry.description, ?entry.notes, ?entry.source],
            ),
      ],
      _LibraryTab.grimoire => [
        const _LibrarySectionHeader(
          title: 'Grimório',
          icon: Icons.auto_awesome,
          accent: RpgTheme.goldBright,
        ),
        for (final spell in controller.spellLibrary)
          if (matches([
            spell.name,
            spell.tier,
            spell.description,
            spell.effect,
            spell.notes,
          ]))
            _LibraryCard(
              icon: Icons.auto_awesome,
              title: spell.name,
              subtitle: spell.tier,
              groupTitle: _spellGroupTitle(spell),
              groupIcon: _spellGroupIcon(spell),
              groupAccent: _spellGroupAccent(spell),
              chips: [
                _LibraryChip('limite', _usageLimitLabel(spell.usageLimit)),
                if (spell.actionCost != null)
                  _LibraryChip('uso', spell.actionCost!),
                if (spell.range != null) _LibraryChip('alcance', spell.range!),
                if (spell.duration != null)
                  _LibraryChip('duração', spell.duration!),
                if (spell.roll != null) _LibraryChip('rolagem', spell.roll!),
              ],
              details: [
                spell.description,
                spell.suggestedTest,
                spell.effect,
                ?spell.extraEffect,
                ?spell.notes,
                ?spell.source,
              ],
            ),
        const _LibrarySectionHeader(title: 'Rituais', icon: Icons.menu_book),
        for (final ritual in controller.ritualLibrary)
          if (matches([
            ritual.name,
            ritual.suggestedRoll,
            ritual.description,
            ritual.difficulty,
          ]))
            _LibraryCard(
              icon: Icons.menu_book,
              title: ritual.name,
              subtitle: 'Ritual',
              groupTitle: 'Rituais',
              groupIcon: Icons.menu_book,
              chips: [
                _LibraryChip('rolagem', ritual.suggestedRoll),
                if (ritual.actionCost != null)
                  _LibraryChip('uso', ritual.actionCost!),
                if (ritual.duration != null)
                  _LibraryChip('duração', ritual.duration!),
              ],
              details: [
                ritual.description,
                ritual.difficulty,
                ?ritual.extraEffect,
                ?ritual.notes,
                ?ritual.source,
              ],
            ),
      ],
      _LibraryTab.powers => [
        const _LibrarySectionHeader(
          title: 'Poderes raciais, classe e divinos',
          icon: Icons.workspace_premium,
        ),
        for (final power in controller.powerLibrary)
          if (matches([
            power.name,
            power.type,
            power.description,
            power.effect,
            power.origin,
            power.notes,
          ]))
            _LibraryCard(
              icon: _powerIcon(power.type),
              title: power.name,
              subtitle: power.type,
              groupTitle: _powerGroupTitle(power),
              groupIcon: _powerIcon(power.type),
              groupAccent: _powerGroupAccent(power),
              chips: [
                _LibraryChip('origem', power.origin ?? power.type),
                _LibraryChip('limite', _usageLimitLabel(power.usageLimit)),
                if (power.actionCost != null)
                  _LibraryChip('uso', power.actionCost!),
                if (power.roll != null) _LibraryChip('rolagem', power.roll!),
              ],
              details: [
                power.description,
                power.suggestedTest,
                power.effect,
                ?power.extraEffect,
                ?power.notes,
                ?power.source,
              ],
            ),
      ],
      _LibraryTab.equipment => [
        for (final equipment in controller.equipmentLibrary)
          if (matches([
            equipment.name,
            equipment.description,
            equipment.origin,
            equipment.damage,
            equipment.effect,
            ...equipment.properties,
          ]))
            _LibraryCard(
              icon: _equipmentIcon(equipment.category),
              title: equipment.name,
              subtitle: _equipmentCategoryLabel(equipment.category),
              groupTitle: _equipmentGroupTitle(equipment.category),
              groupIcon: _equipmentIcon(equipment.category),
              chips: [
                if (equipment.origin != null)
                  _LibraryChip('origem', equipment.origin!),
                if (equipment.damage != null)
                  _LibraryChip('dano', equipment.damage!),
                if (equipment.baseDefense != null)
                  _LibraryChip('defesa', '${equipment.baseDefense}'),
                if (equipment.defenseBonus != 0)
                  _LibraryChip('bônus', '+${equipment.defenseBonus}'),
                if (equipment.usageLimit != null)
                  _LibraryChip(
                    'limite',
                    _usageLimitLabel(equipment.usageLimit!),
                  ),
              ],
              details: [
                equipment.description,
                if (equipment.properties.isNotEmpty)
                  'Propriedades: ${equipment.properties.join(', ')}',
                if (equipment.recommendedClasses.isNotEmpty)
                  'Classes: ${equipment.recommendedClasses.join(', ')}',
                ?equipment.effect,
                ?equipment.notes,
                ?equipment.source,
              ],
            ),
      ],
      _LibraryTab.items => [
        for (final item in controller.itemLibrary)
          if (matches([
            item.name,
            item.type,
            item.description,
            item.roll,
            item.effectKind,
            item.notes,
          ]))
            _LibraryCard(
              icon: Icons.inventory_2,
              title: item.name,
              subtitle: item.type,
              groupTitle: item.effectKind == null
                  ? 'Itens úteis'
                  : 'Consumíveis',
              groupIcon: item.effectKind == null
                  ? Icons.inventory_2
                  : Icons.local_drink,
              chips: [
                if (item.origin != null) _LibraryChip('origem', item.origin!),
                if (item.roll != null) _LibraryChip('rolagem', item.roll!),
                if (item.fixedBonus != 0)
                  _LibraryChip('bônus', '+${item.fixedBonus}'),
                if (item.effectKind != null)
                  _LibraryChip('efeito', _effectKindLabel(item.effectKind!)),
              ],
              details: [
                item.description,
                ?item.extraEffect,
                ?item.notes,
                ?item.source,
              ],
            ),
      ],
      _LibraryTab.kits => [
        for (final kit in controller.starterKits)
          if (matches([kit.name, kit.characterClass, ...kit.items, kit.notes]))
            _LibraryCard(
              icon: Icons.backpack,
              title: kit.name,
              subtitle: kit.characterClass,
              chips: [_LibraryChip('itens', '${kit.items.length}')],
              details: [...kit.items, ?kit.notes, ?kit.source],
            ),
      ],
      _LibraryTab.monsters => [
        for (final monster in controller.monsters)
          if (matches([
            monster.name,
            monster.category,
            monster.attack,
            monster.damage,
            monster.instinct,
            monster.special,
            monster.behavior,
            monster.encounterUse,
          ]))
            _LibraryCard(
              icon: Icons.dangerous,
              title: monster.name,
              subtitle: monster.category,
              accent: RpgTheme.danger,
              chips: [
                _LibraryChip('vida', '${monster.maxHp}'),
                _LibraryChip('defesa', '${monster.defense}'),
                _LibraryChip('dano', monster.damage),
                _LibraryChip('ataque', monster.attack),
              ],
              details: [
                monster.description,
                monster.movement,
                monster.instinct,
                monster.special,
                ?monster.behavior,
                ?monster.encounterUse,
                ?monster.rewards,
                ?monster.notes,
                ?monster.source,
              ],
            ),
      ],
    };

    if (cards.isEmpty) {
      return const Center(
        child: _EmptyState(message: 'Nada encontrado nesta biblioteca.'),
      );
    }
    return _LibraryGrid(children: cards);
  }
}

class _NoCombatState extends StatelessWidget {
  const _NoCombatState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      ornate: true,
      doubleBorder: true,
      raised: true,
      borderColor: RpgTheme.lineGold,
      padding: const EdgeInsets.all(RpgSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final copy = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'Nenhum combate ativo',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: RpgTextStyles.display(
                  size: compact ? 18 : 22,
                  color: RpgTheme.goldBright,
                  weight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: RpgSpacing.sm),
              Text(
                'Inicie um encontro para controlar vida, status, rodada e monstros sem automatizar decisões da mesa.',
                textAlign: compact ? TextAlign.center : TextAlign.start,
                style: const TextStyle(color: RpgTheme.mutedInk),
              ),
            ],
          );
          final portrait = const RpgPortrait(
            label: 'Combate',
            sigil: 'combat',
            icon: Icons.hourglass_empty,
            size: 58,
            color: RpgTheme.gold,
          );
          final button = RpgButton(
            onPressed: onStart,
            icon: Icons.shield,
            label: 'Iniciar combate',
            variant: RpgButtonVariant.primary,
          );

          if (compact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                portrait,
                const SizedBox(height: RpgSpacing.md),
                copy,
                const SizedBox(height: RpgSpacing.lg),
                button,
              ],
            );
          }

          return Row(
            children: [
              portrait,
              const SizedBox(width: RpgSpacing.lg),
              Expanded(child: copy),
              const SizedBox(width: RpgSpacing.lg),
              button,
            ],
          );
        },
      ),
    );
  }
}

String _spellGroupTitle(SpellTemplate spell) {
  final tier = _canonicalOptionName(spell.tier);
  if (tier.contains('fort')) return 'Magias fortes';
  return 'Magias simples';
}

IconData _spellGroupIcon(SpellTemplate spell) {
  return _spellGroupTitle(spell) == 'Magias fortes'
      ? Icons.local_fire_department
      : Icons.auto_awesome;
}

Color _spellGroupAccent(SpellTemplate spell) {
  return _spellGroupTitle(spell) == 'Magias fortes'
      ? RpgTheme.danger
      : RpgTheme.goldBright;
}

String _powerGroupTitle(PowerTemplate power) {
  final type = _canonicalOptionName(power.type);
  final origin = _canonicalOptionName(power.origin ?? '');
  if (type.contains('racial') || origin.contains('raca')) {
    return 'Poderes raciais';
  }
  if (type.contains('divin') || origin.contains('clerigo')) {
    return 'Poderes divinos';
  }
  return 'Habilidades de classe';
}

Color _powerGroupAccent(PowerTemplate power) {
  return switch (_powerGroupTitle(power)) {
    'Poderes divinos' => RpgTheme.goldBright,
    'Poderes raciais' => RpgTheme.mossBright,
    _ => RpgTheme.ochre,
  };
}

String _equipmentGroupTitle(EquipmentCategory category) {
  return switch (category) {
    EquipmentCategory.weapon => 'Armas',
    EquipmentCategory.shield => 'Escudos',
    EquipmentCategory.armor => 'Armaduras',
    EquipmentCategory.accessory => 'Acessórios',
  };
}

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1100
            ? 3
            : constraints.maxWidth > 700
            ? 2
            : 1;
        const spacing = 12.0;
        final displayChildren = _groupedChildren(children);
        return CustomScrollView(
          key: const PageStorageKey('official-library'),
          slivers: [
            const SliverPadding(padding: EdgeInsets.only(top: 22)),
            for (final section in _sections(displayChildren))
              if (section.header != null)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: SliverToBoxAdapter(child: section.header),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => section.cards[index],
                      childCount: section.cards.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      mainAxisExtent: 230,
                    ),
                  ),
                ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 22)),
          ],
        );
      },
    );
  }

  List<_LibraryGridSection> _sections(List<Widget> children) {
    final sections = <_LibraryGridSection>[];
    var cards = <Widget>[];
    void flushCards() {
      if (cards.isEmpty) return;
      sections.add(_LibraryGridSection(cards: cards));
      cards = <Widget>[];
    }

    for (final child in children) {
      if (child is _LibrarySectionHeader) {
        flushCards();
        sections.add(_LibraryGridSection(header: child));
      } else {
        cards.add(child);
      }
    }
    flushCards();
    return sections;
  }

  List<Widget> _groupedChildren(List<Widget> source) {
    final hasGroups = source.whereType<_LibraryCard>().any(
      (card) => card.groupTitle != null,
    );
    if (!hasGroups) {
      return source;
    }

    final grouped = <String, List<Widget>>{};
    final groupIcons = <String, IconData>{};
    final groupAccents = <String, Color>{};
    final loose = <Widget>[];

    for (final child in source) {
      if (child is _LibrarySectionHeader) continue;
      if (child is _LibraryCard && child.groupTitle != null) {
        final title = child.groupTitle!;
        grouped.putIfAbsent(title, () => []);
        grouped[title]!.add(child);
        groupIcons[title] = child.groupIcon ?? child.icon;
        groupAccents[title] = child.groupAccent ?? child.accent;
      } else {
        loose.add(child);
      }
    }

    return [
      ...loose,
      for (final group in grouped.entries) ...[
        _LibrarySectionHeader(
          title: group.key,
          icon: groupIcons[group.key] ?? Icons.auto_stories,
          accent: groupAccents[group.key] ?? RpgTheme.gold,
        ),
        ...group.value,
      ],
    ];
  }
}

class _LibraryGridSection {
  const _LibraryGridSection({this.header, this.cards = const []});

  final Widget? header;
  final List<Widget> cards;
}

class _LibrarySectionHeader extends StatelessWidget {
  const _LibrarySectionHeader({
    required this.title,
    required this.icon,
    this.accent = RpgTheme.gold,
  });

  final String title;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: RpgSpacing.sm, bottom: RpgSpacing.xs),
      child: RpgSectionTitle(title: title, icon: icon, accent: accent),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.details,
    this.chips = const [],
    this.accent = RpgTheme.gold,
    this.groupTitle,
    this.groupIcon,
    this.groupAccent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> details;
  final List<_LibraryChip> chips;
  final Color accent;
  final String? groupTitle;
  final IconData? groupIcon;
  final Color? groupAccent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailDialog(
        context,
        title: title,
        subtitle: subtitle,
        fields: [
          for (final chip in chips) MapEntry(chip.label, chip.value),
          for (final detail in details) MapEntry('Detalhe', detail),
        ],
      ),
      borderRadius: BorderRadius.circular(RpgRadius.md),
      child: RpgPanel(
        inset: true,
        doubleBorder: true,
        borderColor: RpgTheme.lineStrong,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RpgPortrait(label: title, icon: icon, size: 34, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: RpgTextStyles.display(
                      size: 14,
                      color: RpgTheme.inkBright,
                      weight: FontWeight.w700,
                      letterSpacing: 1.05,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RpgTextStyles.eyebrow(size: 9.5, color: accent),
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final chip in chips)
                    RpgStatChip(label: chip.label, value: chip.value),
                ],
              ),
            ],
            if (details.where((item) => item.trim().isNotEmpty).firstOrNull
                case final detail?) ...[
              const SizedBox(height: 10),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryChip {
  const _LibraryChip(this.label, this.value);

  final String label;
  final String value;
}
