import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MindFlowColors {
  static const ink = Color(0xFF080A16);
  static const night = Color(0xFF101629);
  static const panel = Color(0xFF151A31);
  static const purple = Color(0xFF8B5CF6);
  static const blue = Color(0xFF38BDF8);
  static const pink = Color(0xFFFF7AB6);
  static const mint = Color(0xFF7DE2D1);
  static const warning = Color(0xFFFFC857);
}

ThemeData mindFlowTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: MindFlowColors.ink,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MindFlowColors.purple,
      brightness: Brightness.dark,
      primary: MindFlowColors.purple,
      secondary: MindFlowColors.pink,
      tertiary: MindFlowColors.blue,
      surface: MindFlowColors.panel,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: MindFlowColors.pink, width: 1.2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xEE0E1224),
      indicatorColor: MindFlowColors.purple.withValues(alpha: .20),
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
    ),
  );
}

class Glass extends StatelessWidget {
  const Glass(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.radius = 22,
      this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withValues(alpha: .075),
            border: Border.all(color: Colors.white.withValues(alpha: .11)),
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return panel;
    return InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: panel);
  }
}

class GradientScaffold extends StatelessWidget {
  const GradientScaffold(
      {super.key,
      required this.child,
      this.appBar,
      this.bottomNavigationBar,
      this.floatingActionButton});
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF111936), Color(0xFF080A16), Color(0xFF1B1029)],
            ),
          ),
          child: SafeArea(child: child),
        ),
      );
}
