import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'methods.dart';

final newsDetailsProvider = Provider((ref) => NewsDetailsMethods());

final isFabButtonProvider = StateProvider<bool>((ref) => true);
