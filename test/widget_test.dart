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
}
