part of '../shell/session_shell.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RpgSessionController>();

    return Scaffold(
      body: RpgStage(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 34, 20, 52),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: RpgCrest(size: 136)),
                    const SizedBox(height: 26),
                    Text(
                      'RPG dos Guri - Mesa Aberta'.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: RpgTextStyles.eyebrow(
                        color: RpgColors.goldDeep,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O Concílio dos Guri',
                      textAlign: TextAlign.center,
                      style: RpgTextStyles.display(
                        size: 34,
                        color: RpgTheme.goldBright,
                        weight: FontWeight.w600,
                        letterSpacing: 3.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(child: RpgOrnament(width: 240)),
                    const SizedBox(height: 22),
                    _LandingCodePill(
                      code: controller.table.code,
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: controller.table.code),
                        );
                      },
                      onEdit: () => _showTableCodeDialog(context),
                    ),
                    const SizedBox(height: 28),
                    _LandingMasterCard(onTap: controller.enterAsMaster),
                    const SizedBox(height: 18),
                    const RpgSectionTitle(
                      title: 'Fichas aprovadas',
                      icon: Icons.groups,
                    ),
                    const SizedBox(height: 10),
                    if (controller.characters.isEmpty)
                      const _EmptyState(message: 'Nenhuma ficha aprovada.')
                    else
                      _LandingCharacterGrid(controller: controller),
                    const SizedBox(height: 14),
                    RpgButton(
                      onPressed: () => _showJoinRequestDialog(context),
                      icon: Icons.how_to_reg,
                      label: 'Solicitar entrada',
                      variant: RpgButtonVariant.ghost,
                      expand: true,
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'MVP domestico - Firebase como pergaminho da mesa',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: RpgTheme.inkDim, fontSize: 11),
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

class _LandingCodePill extends StatelessWidget {
  const _LandingCodePill({
    required this.code,
    required this.onCopy,
    required this.onEdit,
  });

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RpgPanel(
        ornate: true,
        doubleBorder: true,
        borderColor: RpgTheme.lineGold,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: RpgSpacing.sm,
          runSpacing: RpgSpacing.sm,
          children: [
            Text('MESA', style: RpgTextStyles.eyebrow(size: 9)),
            Text(
              code,
              style: RpgTextStyles.mono(
                color: RpgTheme.goldBright,
                size: 18,
                weight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            RpgIconButton(
              tooltip: 'Copiar código',
              onPressed: onCopy,
              icon: Icons.copy,
            ),
            RpgIconButton(
              tooltip: 'Entrar ou criar mesa',
              onPressed: onEdit,
              icon: Icons.meeting_room,
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingMasterCard extends StatelessWidget {
  const _LandingMasterCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RpgPanel(
      ornate: true,
      doubleBorder: true,
      borderColor: RpgTheme.lineGold,
      danger: true,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            const RpgPortrait(
              label: 'Mestre',
              size: 52,
              sigil: 'master',
              color: RpgTheme.danger,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrar como Mestre',
                    style: RpgTextStyles.display(
                      size: 15,
                      color: RpgTheme.goldBright,
                      weight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Controlar mesa, aprovar jogadores e conduzir combate',
                    style: TextStyle(color: RpgTheme.mutedInk, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: RpgTheme.mutedInk),
          ],
        ),
      ),
    );
  }
}

class _LandingCharacterGrid extends StatelessWidget {
  const _LandingCharacterGrid({required this.controller});

  final RpgSessionController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 460 ? 2 : 1;
        const spacing = RpgSpacing.sm;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final character in controller.characters)
              SizedBox(
                width: width,
                child: RpgPanel(
                  inset: true,
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () => controller.enterAsPlayer(character.id),
                    child: Row(
                      children: [
                        RpgPortrait(
                          label: character.name,
                          size: 44,
                          sigil: character.characterClass,
                          color: RpgTheme.lineGold,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RpgTextStyles.body(
                                  size: 12.5,
                                  color: RpgTheme.inkBright,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${character.characterClass} - nv ${character.level}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: RpgTheme.mutedInk,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        RpgStateLamp(
                          state: character.currentHp <= 0
                              ? DefeatedState.unconscious
                              : DefeatedState.active,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
