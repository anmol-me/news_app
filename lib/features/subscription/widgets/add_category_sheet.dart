import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/features/subscription/repository/add_subscription_repository.dart';
import 'package:news_app/features/subscription/repository/category_list_repo.dart';

import '../../../common/common_widgets.dart';
import '../../../common/constants.dart';
import '../screens/select_subscription_screen/select_subscription_screen.dart';

final isCreateCatLoadingProvider = StateProvider<bool>((ref) => false);

// Future<void> showAddCategorySheet(
//   BuildContext context,
//   WidgetRef ref,
//   TextEditingController catNameController,
// ) {
//
//
//   return showModalBottomSheet(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(15),
//       ),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SizedBox(
//           height: MediaQuery.of(context).copyWith().size.height * 0.45,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: catNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Category Name',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: colorRed),
//                 onPressed: () {},
//                 child: const Text('Create Category'),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

class AddCatSheetButton extends ConsumerWidget {
  final TextEditingController catNameController;

  const AddCatSheetButton({
    super.key,
    required this.catNameController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = false;

    final mediaQuery = MediaQuery.of(context);

    // final isCreateCatLoading = ref.watch(isCreateCatLoadingProvider);
    // final isCreateCatLoadingController =
    //     ref.watch(isCreateCatLoadingProvider.notifier);

    /// Create Category
    void createCategory(StateSetter setState) {
      // final addNewSubsController =
      //     ref.read(addNewSubscriptionProvider.notifier);

      final categoryListController =
          ref.read(categoryListNotifierProvider.notifier);

      // final isCreateCatLoadingController =
      // ref.read(isCreateCatLoadingProvider.notifier);

      // isCreateCatLoadingController.update((state) => true);

      setState(() => isLoading = true);

      // addNewSubsController

      categoryListController
          .createCategory(
        catNameController.text,
        context,
      )
          .then((_) {
        setState(() => isLoading = false);
        catNameController.clear();
        // Navigator.of(context).pushNamed(SelectSubscriptionScreen.routeNamed);
      });
    }

    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          builder: (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter set) {
              return Padding(
                padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: mediaQuery.size.height * 0.45,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: catNameController,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorRed,
                              ),
                              onPressed: () => createCategory(set),
                              child: isLoading
                                  ? const CircularLoading()
                                  : const Text('Create Category'),
                            ),
                            isLoading
                                ? TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorDisabled,
                                    ),
                                    onPressed: null,
                                    child: const Text('Close'),
                                  )
                                : TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorRed,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------------

// class AddCatSheetButton extends ConsumerStatefulWidget {
//   final TextEditingController catNameController;
//
//   const AddCatSheetButton({
//     super.key,
//     required this.catNameController,
//   });
//
//   @override
//   ConsumerState createState() => _AddCatSheetButtonState();
// }
//
// class _AddCatSheetButtonState extends ConsumerState<AddCatSheetButton> {
// // class AddCatSheetButton extends ConsumerStatefulWidget {
// //   final TextEditingController catNameController;
// //
// //   const AddCatSheetButton({
// //     super.key,
// //     required this.catNameController,
// //   });
// //
// //   @override
// //   State<AddCatSheetButton> createState() => _AddCatSheetButtonState();
// // }
// //
// // class _AddCatSheetButtonState extends State<AddCatSheetButton> {
//   bool isLoading = false;
//
//   void createCategory(StateSetter setState) {
//     final addNewSubsController = ref.read(addNewSubscriptionProvider.notifier);
//
//     // final isCreateCatLoadingController =
//     // ref.read(isCreateCatLoadingProvider.notifier);
//
//     // isCreateCatLoadingController.update((state) => true);
//
//     setState(() => isLoading = true);
//
//     addNewSubsController
//         .createCategory(
//           widget.catNameController.text,
//           context,
//         )
//         .then(
//           (_) => setState(() => isLoading = false),
//         );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     log('BUTTONNNNNNNNNNNNNNNNNNNNNNNNNNNNNN');
//
//     final mediaQuery = MediaQuery.of(context);
//
//     final addNewSubsController = ref.watch(addNewSubscriptionProvider.notifier);
//
//     final isCreateCatLoading = ref.watch(isCreateCatLoadingProvider);
//     final isCreateCatLoadingController =
//         ref.watch(isCreateCatLoadingProvider.notifier);
//
//     return IconButton(
//       icon: const Icon(Icons.add),
//       onPressed: () {
//         showModalBottomSheet(
//           isScrollControlled: true,
//           context: context,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(15),
//             ),
//           ),
//           builder: (context) => StatefulBuilder(
//             builder: (BuildContext context, StateSetter set) {
//               return Padding(
//                 padding: mediaQuery.viewInsets,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SizedBox(
//                     height: mediaQuery.size.height * 0.45,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         TextFormField(
//                           controller: widget.catNameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Category Name',
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: colorRed,
//                           ),
//                           onPressed: () => createCategory(set),
//                           child: isLoading
//                               ? const CircularLoading()
//                               : const Text('Create Category'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
