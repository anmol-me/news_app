import 'package:flutter/material.dart';

import 'common/constants.dart';

@immutable
class AppTheme{
  ThemeData lightThemeData() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      //
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
      ),
      //
      colorScheme: ColorScheme.fromSwatch().copyWith(
        background: Colors.grey.shade50,
        surface: Colors.grey.shade50,
        surfaceTint: Colors.grey.shade50,
        outline: Colors.black54,
      ),
      //
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorAppbarForeground,
        selectionColor: Colors.red.shade100,
      ),
      //
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorRed,
          foregroundColor: Colors.white,
        ),
      ),
      //
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorRed,
          foregroundColor: Colors.white,
        ),
      ),
      //
      appBarTheme: AppBarTheme(
        color: colorAppbarBackground,
        foregroundColor: colorAppbarForeground,
        elevation: 0,
      ),
    );
  }

  ThemeData darkThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}