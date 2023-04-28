import 'package:flutter_riverpod/flutter_riverpod.dart';

final isDemoProvider = StateProvider<bool>((ref) => false);

final emptyStateDisableProvider = StateProvider((ref) => false);
