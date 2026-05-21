import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/rpg_app.dart';
import 'features/rpg/application/application.dart';
import 'features/rpg/data/firestore_rpg_repositories.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (error, stackTrace) {
    debugPrint('Firebase indisponivel; usando estado local seedado: $error');
    debugPrint('$stackTrace');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        if (!firebaseReady) return RpgSessionController.seeded();
        final firestore = FirebaseFirestore.instance;
        return RpgSessionController.firestore(
          tableRepository: FirestoreTableRepository(firestore),
          characterRepository: FirestoreCharacterRepository(firestore),
          combatRepository: FirestoreCombatRepository(firestore),
          actionLogRepository: FirestoreActionLogRepository(firestore),
        );
      },
      child: const RpgApp(),
    ),
  );
}
