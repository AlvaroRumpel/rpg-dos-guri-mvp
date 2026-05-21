import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RpgColors {
  const RpgColors._();

  static const bgDeep = Color(0xff0c0a08);
  static const bgBase = Color(0xff15110d);
  static const bgRaised = Color(0xff1d1813);
  static const bgInset = Color(0xff0a0805);
  static const bgGlass = Color(0xb81c1611);

  static const lineFaint = Color(0xff2a2218);
  static const line = Color(0xff3a2f23);
  static const lineStrong = Color(0xff5a4a36);
  static const lineGold = Color(0xff8a7549);

  static const ink = Color(0xffd4c8a8);
  static const inkBright = Color(0xffece1c2);
  static const mutedInk = Color(0xff8a7e62);
  static const inkDim = Color(0xff5a513e);
  static const inkFaint = Color(0xff3d3628);

  static const gold = Color(0xffc8a960);
  static const goldBright = Color(0xffe8c987);
  static const goldDeep = Color(0xff8a7035);
  static const goldShadow = Color(0xff4a3a18);

  static const blood = Color(0xff7a1d1d);
  static const bloodBright = Color(0xffb32f2f);
  static const ember = Color(0xffc47b3a);
  static const emberBright = Color(0xffe89758);
  static const moss = Color(0xff4a5d3a);
  static const mossBright = Color(0xff6f8855);
  static const steel = Color(0xff6e7884);
  static const steelBright = Color(0xff98a3b0);
  static const crimson = Color(0xff8c2829);
  static const charcoal = Color(0xff3a3a3a);
}

class RpgSpacing {
  const RpgSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const xxl = 32.0;
}

class RpgRadius {
  const RpgRadius._();

  static const sm = 2.0;
  static const md = 3.0;
  static const lg = 4.0;
}

class RpgShadows {
  const RpgShadows._();

  static const inset = [
    BoxShadow(color: Color(0x0de8c987), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x99000000), offset: Offset(0, -1)),
  ];

  static const lift = [
    BoxShadow(color: Color(0x73000000), blurRadius: 28, offset: Offset(0, 12)),
  ];

  static const deep = [
    BoxShadow(color: Color(0xbf000000), blurRadius: 60, offset: Offset(0, 24)),
    BoxShadow(color: Color(0x99000000), offset: Offset(0, 2)),
  ];
}

class RpgTextStyles {
  const RpgTextStyles._();

  static TextStyle display({
    double size = 16,
    Color color = RpgColors.inkBright,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 1.8,
  }) {
    return GoogleFonts.cinzel(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle eyebrow({
    double size = 10,
    Color color = RpgColors.mutedInk,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 1.8,
  }) {
    return GoogleFonts.cinzel(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono({
    double size = 12,
    Color color = RpgColors.inkBright,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.jetBrainsMono(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double size = 13,
    Color color = RpgColors.ink,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.manrope(
      color: color,
      fontSize: size,
      fontWeight: weight,
    );
  }

  static TextStyle button({
    double size = 11,
    Color color = RpgColors.goldBright,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.cinzel(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: 1.4,
    );
  }
}

class RpgTheme {
  const RpgTheme._();

  static const bgDeep = RpgColors.bgDeep;
  static const bgBase = RpgColors.bgBase;
  static const bgRaised = RpgColors.bgRaised;
  static const bgInset = RpgColors.bgInset;
  static const line = RpgColors.line;
  static const lineStrong = RpgColors.lineStrong;
  static const lineGold = RpgColors.lineGold;
  static const ink = RpgColors.ink;
  static const inkBright = RpgColors.inkBright;
  static const mutedInk = RpgColors.mutedInk;
  static const inkDim = RpgColors.inkDim;
  static const wine = RpgColors.blood;
  static const wineDark = Color(0xff4f1414);
  static const moss = RpgColors.moss;
  static const mossBright = RpgColors.mossBright;
  static const brass = RpgColors.gold;
  static const gold = RpgColors.gold;
  static const goldBright = RpgColors.goldBright;
  static const ochre = RpgColors.ember;
  static const danger = RpgColors.bloodBright;
  static const blood = RpgColors.blood;
  static const charcoal = RpgColors.charcoal;
  static const steel = RpgColors.steel;
  static const border = line;

  static ThemeData get light {
    const colorScheme = ColorScheme.dark(
      primary: gold,
      onPrimary: bgDeep,
      secondary: mossBright,
      onSecondary: bgDeep,
      tertiary: ochre,
      onTertiary: bgDeep,
      surface: bgBase,
      onSurface: ink,
      error: danger,
      onError: inkBright,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgDeep,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
    );

    final textTheme = GoogleFonts.manropeTextTheme(
      base.textTheme,
    ).apply(bodyColor: ink, displayColor: inkBright);

    return base.copyWith(
      textTheme: textTheme.copyWith(
        headlineMedium: RpgTextStyles.display(
          size: 26,
          color: goldBright,
          letterSpacing: 2.4,
        ),
        titleLarge: RpgTextStyles.display(
          size: 18,
          color: inkBright,
          weight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: inkBright,
          fontWeight: FontWeight.w800,
        ),
        titleSmall: RpgTextStyles.eyebrow(
          size: 11,
          color: gold,
          weight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: ink),
        bodySmall: textTheme.bodySmall?.copyWith(color: mutedInk),
        labelLarge: RpgTextStyles.button(),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgBase,
        foregroundColor: inkBright,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: null,
        shape: Border(bottom: BorderSide(color: lineGold)),
      ),
      cardTheme: const CardThemeData(
        color: bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(RpgRadius.lg)),
          side: BorderSide(color: line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgInset,
        selectedColor: gold.withValues(alpha: 0.16),
        disabledColor: bgBase,
        side: const BorderSide(color: line),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(color: inkBright),
        iconTheme: const IconThemeData(color: gold, size: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RpgRadius.sm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgRaised,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: RpgTextStyles.display(size: 18, color: goldBright),
        contentTextStyle: const TextStyle(color: ink),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(RpgRadius.lg)),
          side: BorderSide(color: lineGold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RpgSpacing.md,
          vertical: RpgSpacing.md,
        ),
        filled: true,
        fillColor: bgInset,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RpgRadius.md),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RpgRadius.md),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RpgRadius.md),
          borderSide: const BorderSide(color: RpgColors.goldDeep, width: 1.4),
        ),
        labelStyle: RpgTextStyles.eyebrow(size: 10),
        hintStyle: const TextStyle(color: inkDim),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: bgRaised,
          foregroundColor: goldBright,
          disabledBackgroundColor: line,
          disabledForegroundColor: inkDim,
          side: const BorderSide(color: RpgColors.goldDeep),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RpgRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: RpgTextStyles.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldBright,
          side: const BorderSide(color: lineGold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RpgRadius.md),
          ),
          textStyle: RpgTextStyles.button(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldBright,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RpgRadius.md),
          ),
          textStyle: RpgTextStyles.button(size: 10),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: goldBright,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RpgRadius.md),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: ink),
        inputDecorationTheme: InputDecorationTheme(fillColor: bgInset),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: bgInset,
        contentTextStyle: TextStyle(color: inkBright),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: mossBright,
        linearTrackColor: bgInset,
      ),
    );
  }

  static BoxDecoration stageDecoration() {
    return const BoxDecoration(
      color: bgDeep,
      gradient: RadialGradient(
        center: Alignment(0, -0.9),
        radius: 1.18,
        colors: [Color(0x18200f07), bgDeep],
        stops: [0, 1],
      ),
    );
  }

  static BoxDecoration panelDecoration({
    Color borderColor = line,
    bool ornate = false,
    bool inset = false,
    bool raised = false,
    bool danger = false,
  }) {
    return BoxDecoration(
      color: inset
          ? bgInset
          : raised
          ? bgRaised
          : bgBase,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          if (danger) blood.withValues(alpha: 0.18),
          if (!danger) gold.withValues(alpha: raised ? 0.04 : 0.025),
          inset
              ? bgInset
              : raised
              ? bgRaised
              : bgBase,
        ],
      ),
      border: Border.all(color: borderColor, width: ornate ? 1.2 : 1),
      borderRadius: BorderRadius.circular(RpgRadius.md),
      boxShadow: raised ? RpgShadows.lift : RpgShadows.inset,
    );
  }
}
