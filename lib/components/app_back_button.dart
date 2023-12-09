import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/constants.dart';
import '../config/themes.dart';

class AppBackButton extends ConsumerWidget {
  final bool controller;

  const AppBackButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    void onPressedFunction() => controller ? null : Navigator.of(context).pop();

    return themeMode == ThemeMode.light
        ? BackButton(
            color: controller ? colorDisabled : colorAppbarForeground,
            onPressed: onPressedFunction,
          )
        : BackButton(
            color: controller ? Colors.grey[600] : Colors.white,
            onPressed: onPressedFunction,
          );
  }
}
