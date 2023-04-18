import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/category/repository/category_repo.dart';
import 'package:news_app/features/category/screens/category_screen.dart';

import '../../models/news.dart';
import '../authentication/repository/auth_repo.dart';

// final categoryNotifierProvider =
//     StateNotifierProvider<CategoryNotifier, List<News>>((ref) {
//   final userPrefs = ref.watch(userPrefsProvider);
//   final userPassEncoded = ref.watch(userPrefsProvider).getAuthData();
//
//   return CategoryNotifier(
//     // ref,
//     userPrefs,
//     userPassEncoded!,
//   );
// });

// final categoryNotifierProvider = NotifierProvider<CategoryNotifier, List<News>>(() {
//   final userPrefs = ref.watch(userPrefsProvider);
//   final userPassEncoded = ref.watch(userPrefsProvider).getAuthData();
//
//   return CategoryNotifier(userPrefs, userPassEncoded);
// });