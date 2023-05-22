import 'package:flutter_riverpod/flutter_riverpod.dart';

final emptyStateDisableProvider = StateProvider((ref) => false);

final disableFilterProvider = StateProvider((ref) => false);

final isDrawerOpenProvider = StateProvider((ref) => false);