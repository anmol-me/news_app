import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/common_methods.dart';
import '../../../common/constants.dart';

class HomeRefreshButton extends ConsumerWidget {
  const HomeRefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => ref.read(refreshProvider).refreshAllMain(context),
      icon: Icon(
        Icons.refresh,
        color: colorRed,
      ),
    );
  }
}