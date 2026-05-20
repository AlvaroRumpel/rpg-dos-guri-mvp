import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:rpg_dos_guri/app/rpg_app.dart';
import 'package:rpg_dos_guri/features/rpg/state/rpg_session_controller.dart';

void main() {
  testWidgets('shows the RPG session landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RpgSessionController.seeded(),
        child: const RpgApp(),
      ),
    );

    expect(find.text('RPG dos Guri'), findsOneWidget);
    expect(find.text('Entrar como mestre'), findsOneWidget);
    expect(find.text('Criar ficha de jogador'), findsOneWidget);
  });
}
