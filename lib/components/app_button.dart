import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/constants.dart';
import '../config/themes.dart';

class AppButton extends ConsumerWidget {
  final String text;
  final double? fontSize;
  final Color? fontColor;
  final IconData? icon;
  final Color? iconColor;
  final double? leftSpace;
  final VoidCallback? onTap;

  const AppButton(
      this.text, {
        super.key,
        this.fontSize = 17,
        this.fontColor = Colors.black87,
        this.icon,
        this.iconColor,
        this.leftSpace = 6.0,
        this.onTap,
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isLight = themeMode == ThemeMode.light;

    return InkWell(
      splashColor: isLight ? Colors.red.shade100 : null,
      hoverColor: isLight ? Colors.red.shade50 : null,
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, color: iconColor ?? colorRed),
          SizedBox(width: leftSpace),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: isLight ? fontColor : Colors.white,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}