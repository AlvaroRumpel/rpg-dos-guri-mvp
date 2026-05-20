import 'package:flutter/material.dart';

class RpgTheme {
  const RpgTheme._();

  static const parchment = Color(0xfff4ead6);
  static const parchmentLight = Color(0xfffffbef);
  static const parchmentDark = Color(0xffdfc99d);
  static const ink = Color(0xff251811);
  static const mutedInk = Color(0xff6c5941);
  static const wine = Color(0xff7b2f2b);
  static const wineDark = Color(0xff58201e);
  static const moss = Color(0xff3f5f3a);
  static const brass = Color(0xffa56f2b);
  static const ochre = Color(0xffb7892e);
  static const danger = Color(0xff9d2b2e);
  static const charcoal = Color(0xff37302a);
  static const border = Color(0xffcfb98f);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: wine,
        onPrimary: Colors.white,
        secondary: moss,
        onSecondary: Colors.white,
        tertiary: brass,
        onTertiary: Colors.white,
        surface: parchmentLight,
        onSurface: ink,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: parchment,
    );

    final textTheme = base.textTheme.apply(bodyColor: ink, displayColor: ink);

    return base.copyWith(
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: wineDark,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: wineDark,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: mutedInk,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: parchment,
        foregroundColor: ink,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: wineDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: const CardThemeData(
        color: parchmentLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: parchmentDark.withValues(alpha: 0.42),
        selectedColor: brass.withValues(alpha: 0.22),
        disabledColor: parchmentDark.withValues(alpha: 0.24),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: parchmentLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: wine, width: 1.6),
        ),
        labelStyle: const TextStyle(color: mutedInk),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: wine,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: wineDark,
          side: const BorderSide(color: brass),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: wineDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: wineDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: charcoal,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: moss,
        linearTrackColor: parchmentDark,
      ),
    );
  }
}
