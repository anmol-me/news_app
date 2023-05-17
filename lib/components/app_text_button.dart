import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../themes.dart';

class AppTextButton extends ConsumerWidget {
  final String data;
  final void Function()? onPressed;

  const AppTextButton(
    this.data, {
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isLight = themeMode == ThemeMode.light;

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: isLight ? colorRed : Colors.white,
      ),
      onPressed: onPressed,
      child: Text(
        data,
      ),
    );
  }
}
