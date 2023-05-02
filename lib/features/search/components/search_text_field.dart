import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';
import '../repository/search_repo.dart';

class SearchTextField extends ConsumerWidget {
  final TextEditingController searchTextController;
  final GlobalKey<FormState> formKey;

  const SearchTextField({
    super.key,
    required this.searchTextController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchNotifierController = ref.watch(searchNotifierProvider.notifier);

    return TextFormField(
      controller: searchTextController,
      onFieldSubmitted: (_) => searchNotifierController.searchFunction(
        searchTextController,
        formKey,
        context,
      ),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => searchNotifierController.searchFunction(
            searchTextController,
            formKey,
            context,
          ),
        ),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: colorRed,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        suffixIconColor: colorAppbarForeground,
      ),
      validator: (val) {
        if (searchTextController.text.isNotEmpty) {
          return null;
        } else {
          return ErrorString.validUrl.value;
        }
      },
    );
  }
}
