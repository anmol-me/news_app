import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:news_app/common/common_widgets.dart';
import 'package:news_app/common/enums.dart';
import 'package:url_launcher/url_launcher.dart';

String getContent(String content) {
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
        showErrorSnackBar(
          context: context,
          text: ErrorString.notOpenLink.value,
        );
      }
    }
  }
}
