import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_widgets/app_image.dart';

class FirstSearchWidget extends ConsumerWidget {
  const FirstSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Expanded(
      child: Center(
        child: AppImage(
          'assets/images/search_results.png',
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
