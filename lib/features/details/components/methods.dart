import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';

String getContent(String content) {
  /// Content
  // final contentStripped = Bidi.stripHtmlIfNeeded(content);
  final preContent = content.replaceAll('</p>', '\n\n');
  final document = parse(preContent);
  final contentStripped = parse(document.body!.text).documentElement!.text;
  final contentFormatted = utf8.decode(contentStripped.runes.toList());
  return contentFormatted;
}

class NewsDetailsMethods {
  void openLink(
    String link,
    BuildContext context,
  ) async {
    final uri = Uri.parse(link);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An Error Occurred!'),
            content: const Text('Could not load the page.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
  }
}
