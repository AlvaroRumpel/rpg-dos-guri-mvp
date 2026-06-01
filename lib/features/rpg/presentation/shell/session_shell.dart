import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/rpg_theme.dart';
import '../../application/application.dart';
import '../../domain/domain.dart';
import '../widgets/rpg_design_widgets.dart';

part '../landing/landing_view.dart';
part '../master/master_view.dart';
part '../combat/combat_panel.dart';
part '../player/player_view.dart';
part '../cards/rpg_cards.dart';
part '../dialogs/rpg_dialogs.dart';
part '../utils/form_helpers.dart';
part '../utils/view_labels.dart';

class SessionShell extends StatelessWidget {
  const SessionShell({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.select<RpgSessionController, UserRole>(
      (controller) => controller.role,
    );

    return switch (role) {
      UserRole.master => const MasterView(),
      UserRole.player => const PlayerView(),
      UserRole.landing => const LandingView(),
    };
  }
}

enum _MasterScene { table, roster, library, log }

enum _PlayerTab { sheet, powers, items, status }
