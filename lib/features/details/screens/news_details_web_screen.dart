import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsDetailsWebScreen extends ConsumerWidget {
  final String link;

  const NewsDetailsWebScreen({
    super.key,
    required this.link,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: link,
    );
  }
}
