import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../features/settings/repository/settings_repository.dart';

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDarkModeEnabled = ref.watch(userSettingsProvider);

  if (isDarkModeEnabled == null) {
    return ThemeMode.light;
  } else if (isDarkModeEnabled) {
    return ThemeMode.dark;
  } else {
    return ThemeMode.light;
  }
});

@immutable
class AppTheme {
  final TextStyle? headlineLarge = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );

  final TextStyle? bodyLarge = const TextStyle(
    fontSize: 19,
    height: 1.4,
  );

  final TextStyle? labelLarge = TextStyle(
    color: colorSubtitle,
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  final TextStyle? titleMedium = const TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  ThemeData lightThemeData() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      //
      textTheme: TextTheme(
        headlineLarge: headlineLarge,
        bodyLarge: bodyLarge,
        labelLarge: labelLarge,
        titleMedium: titleMedium,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorRed,
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
      textTheme: TextTheme(
        headlineLarge: headlineLarge,
        bodyLarge: bodyLarge,
        labelLarge: labelLarge,
        titleMedium: titleMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
    );
  }
}
