import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/models/news.dart';

import '../features/authentication/repository/user_preferences.dart';
import '../features/category/repository/category_repo.dart';
import '../features/details/components/providers.dart';
import '../features/home/providers/home_providers.dart';
import '../features/search/repository/search_repo.dart';
import '../common/constants.dart';
import '../common/enums.dart';
import '../themes.dart';

class LinearLoader extends StatelessWidget {
  const LinearLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: colorRed,
      backgroundColor: colorAppbarBackground,
    );
  }
}

class CircularLoading extends StatelessWidget {
  final Color? color;

  const CircularLoading({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.7,
      ),
    );
  }
}

class CircularLoadingImage extends StatelessWidget {
  final Color? color;

  const CircularLoadingImage({
    super.key,
    this.color = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: colorRed,
      strokeWidth: 1,
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required String text,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Text(text),
    ),
  );
}