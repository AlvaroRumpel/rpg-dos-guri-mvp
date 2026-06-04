import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rpg_dos_guri/app/rpg_app.dart';
import 'package:rpg_dos_guri/features/rpg/application/application.dart';
import 'package:rpg_dos_guri/features/rpg/domain/domain.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the RPG session landing screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RpgSessionController.seeded(),
        child: const RpgApp(),
      ),
    );

    expect(find.text('RPG DOS GURI - MESA ABERTA'), findsOneWidget);
    expect(find.text('Entrar como Mestre'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.textContaining('SOLICITAR'), findsOneWidget);
  });

  testWidgets('opens a library card detail modal on expanded width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RpgSessionController.seeded();
    controller.monsters = const [
      MonsterTemplate(
        id: 'rato',
        name: 'Rato de Porão Gigante',
        category: 'Muito fraco',
        defense: 9,
        maxHp: 2,
        attack: '1d20 + Agilidade',
        damage: '1',
        movement: 'Rápido, rastejante',
        instinct: 'Morder e fugir',
        special: 'Enxame Irritante',
        description: 'Bando, pressão, distração',
      ),
    ];

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: controller, child: const RpgApp()),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    controller.enterAsMaster();
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Biblioteca').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('Rato de').first);
    await tester.tap(find.textContaining('Rato de').first);
    await tester.pumpAndSettle();

    expect(find.text('Muito fraco'), findsWidgets);
    expect(find.text('Fechar'), findsOneWidget);
  });

  testWidgets('opens player power detail modal on compact width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RpgSessionController.seeded();
    controller.updateCharacter(
      controller.characters.first.copyWith(
        powers: const [
          PowerEntry(
            id: 'corpo-de-pedra',
            name: 'Corpo de Pedra',
            type: 'Poder racial',
            description: 'Resiste ao impacto.',
            suggestedTest: 'Conforme situação',
            effect: 'Reduz dano.',
            usageLimit: UsageLimit.combat,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: controller, child: const RpgApp()),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    controller.enterAsPlayer(controller.characters.first.id);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('PODERES').first);
    await tester.tap(find.textContaining('PODERES').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corpo de Pedra'));
    await tester.pumpAndSettle();

    expect(find.text('Poder racial'), findsWidgets);
    expect(find.text('Fechar'), findsOneWidget);
  });

  testWidgets('player notes render @mentions as plain text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RpgSessionController.seeded();
    final character = controller.characters.first;
    final now = DateTime(2026, 6, 4, 12);
    controller.upsertCharacterNote(
      character.id,
      CampaignNote(
        id: 'note-mention',
        createdAt: now,
        updatedAt: now,
        title: 'Diario',
        body: '@Bardo sem link',
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: controller, child: const RpgApp()),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    controller.enterAsPlayer(character.id);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('NOTAS').first);
    await tester.tap(find.textContaining('NOTAS').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('@Bardo sem link'));
    await tester.tap(find.text('@Bardo sem link'));
    await tester.pumpAndSettle();

    expect(find.text('@Bardo sem link'), findsOneWidget);
    expect(find.text('Fechar'), findsNothing);
  });
}
