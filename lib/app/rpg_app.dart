import 'package:flutter/material.dart';

import 'rpg_theme.dart';
import '../features/rpg/views/session_shell.dart';

class RpgApp extends StatelessWidget {
  const RpgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RPG dos Guri',
      theme: RpgTheme.light,
      home: const SessionShell(),
    );
  }
}
