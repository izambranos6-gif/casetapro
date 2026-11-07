import 'package:flutter/material.dart';

/// Paleta visual interna de CasetaPro.
/// No se utiliza en el reporte neutro exportado.
abstract class AppColors {
  static const navy = Color(0xFF102E51);
  static const navyDeep = Color(0xFF09233F);
  static const sea = Color(0xFF1679B8);
  static const cyan = Color(0xFF21B9CE);
  static const green = Color(0xFF159E75);
  static const orange = Color(0xFFECA34B);
  static const violet = Color(0xFF7761C8);
  static const background = Color(0xFFF2F7FB);
  static const ink = Color(0xFF172F4A);
  static const muted = Color(0xFF687F93);
  static const stroke = Color(0xFFD9E5EF);
  static const lightBlue = Color(0xFFE7F3FC);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.sea,
    primary: AppColors.sea,
    secondary: AppColors.green,
    surface: Colors.white,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDeep,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -.35,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 29, fontWeight: FontWeight.w900,
        letterSpacing: -.8, color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 21, fontWeight: FontWeight.w800,
        letterSpacing: -.5, color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(color: AppColors.ink, height: 1.3),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.stroke, thickness: .8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFBFDFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.stroke, width: 1.15),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.sea, width: 1.9),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFCC5F60)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: const BorderSide(color: AppColors.stroke),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.sea,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.navy,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
  );
}
