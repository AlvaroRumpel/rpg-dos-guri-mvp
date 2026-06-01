import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rpg_dos_guri/app/rpg_app.dart';
import 'package:rpg_dos_guri/features/rpg/application/application.dart';

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
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RpgSessionController.seeded(),
        child: const RpgApp(),
      ),
    );

    expect(find.text('RPG DOS GURI - MESA ABERTA'), findsOneWidget);
    expect(find.text('Entrar como Mestre'), findsOneWidget);
    expect(find.text('Solicitar entrada'), findsOneWidget);
  });

  testWidgets('opens a library card detail modal on expanded width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = RpgSessionController.seeded();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: controller, child: const RpgApp()),
    );
    await tester.pumpAndSettle();
    controller.enterAsMaster();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Biblioteca'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rato de Porão Gigante'));
    await tester.pumpAndSettle();

    expect(find.text('Muito fraco'), findsWidgets);
    expect(find.text('Fechar'), findsOneWidget);
  });

  testWidgets('opens player power detail modal on compact width', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = RpgSessionController.seeded();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: controller, child: const RpgApp()),
    );
    await tester.pumpAndSettle();
    controller.enterAsPlayer(controller.characters.first.id);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Poderes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corpo de Pedra'));
    await tester.pumpAndSettle();

    expect(find.text('Poder racial'), findsWidgets);
    expect(find.text('Fechar'), findsOneWidget);
  });
}
