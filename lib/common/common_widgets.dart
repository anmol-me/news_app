import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/details/components/providers.dart';
import '../features/home/providers/home_providers.dart';
import 'constants.dart';
import 'enums.dart';

class LinearLoader extends StatelessWidget {
  const LinearLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: colorRed,
      // backgroundColor: Colors.red[100],
      backgroundColor: colorAppbarBackground,
    );
  }
}

class CircularLoading extends StatelessWidget {
  final Color? color;

  const CircularLoading({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.7,
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required String text,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar({
  required BuildContext context,
  required String text,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Text(text),
    ),
  );
}

class ReadButton extends ConsumerWidget {
  const ReadButton({
    super.key,
    required this.entryId,
  });

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);
    final newsNotifierController = ref.watch(homeFeedProvider.notifier);

    final newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    return InkWell(
      onTap: () {
        Status stat;

        newsItem.status == Status.read
            ? stat = Status.unread
            : stat = Status.read;

        newsNotifierController.toggleRead(
          entryId,
          stat,
          context,
        );
      },
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            size: 27,
            color: colorRed,
            newsItem.status == Status.unread
                ? Icons.circle
                : Icons.circle_outlined,
          ),
          const SizedBox(width: 6),
          newsItem.status == Status.unread
              ? const BarTextButton(text: 'Unread')
              : const BarTextButton(text: 'Read'),
        ],
      ),
    );
  }
}

class StarredButton extends ConsumerWidget {
  const StarredButton({
    super.key,
    required this.entryId,
  });

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);
    final newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    return InkWell(
      onTap: () {
        ref.read(homeFeedProvider.notifier).toggleFavStatus(
              newsItem.entryId,
              context,
            );
      },
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            size: 27,
            color: colorAppbarForeground,
            newsItem.isFav ? Icons.bookmark_added : Icons.bookmark_add,
          ),
          const SizedBox(width: 6),
          newsItem.isFav
              ? const BarTextButton(text: 'Unstar')
              : const BarTextButton(text: 'Star'),
        ],
      ),
    );
  }
}

class OpenLinkButton extends ConsumerWidget {
  final String url;

  const OpenLinkButton({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsDetails = ref.watch(newsDetailsProvider);

    return InkWell(
      onTap: () => newsDetails.openLink(url, context),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(Icons.link, color: colorRed),
          const SizedBox(width: 6),
          const BarTextButton(text: 'Open link'),
        ],
      ),
    );
  }
}

class BarTextButton extends StatelessWidget {
  final String text;
  final double size;
  final Color textColor;

  const BarTextButton({
    super.key,
    required this.text,
    this.size = 17,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: textColor,
      ),
    );
  }
}
