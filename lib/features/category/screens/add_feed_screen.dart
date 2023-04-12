import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddFeedScreen extends HookConsumerWidget {
  final String catListItemTitle;

  const AddFeedScreen({
    super.key,
    required this.catListItemTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // final _formKey = useMemoized(GlobalKey<FormState>.new, const []);

    final urlController = useTextEditingController(
        text: 'https://feeds.feedburner.com/TheHackersNews');

    return Scaffold(
      appBar: AppBar(
        title: Text('Add feed to $catListItemTitle'),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
