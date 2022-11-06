import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/home/repository/home_feed_repo.dart';
import '../features/starred/starred_repo.dart';
import '../features/starred/starred_screen.dart';
import '../models/news.dart';
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
      backgroundColor: Theme.of(context).errorColor,
      content: Text(text),
    ),
  );
}

class ReadButton extends ConsumerWidget {
  const ReadButton({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);

    final newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Status stat;

            newsItem.status == Status.read
                ? stat = Status.unread
                : stat = Status.read;

            ref.read(homeFeedProvider.notifier).toggleRead(
                  entryId,
                  stat,
                  context,
                );
          },
          child: Icon(
            size: 27,
            color: colorRed,
            newsItem.status == Status.unread
                ? Icons.circle
                : Icons.circle_outlined,
          ),
        ),
        const SizedBox(width: 10),
        newsItem.status == Status.unread
            ? const BarTextButton(text: 'Unread')
            : const BarTextButton(text: 'Read'),
      ],
    );
  }
}

class StarredButton extends ConsumerWidget {
  const StarredButton({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);

    final newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () {
            ref.read(homeFeedProvider.notifier).toggleFavStatus(
                  newsItem.entryId,
                  context,
                );
          },
          child: Icon(
            size: 27,
            color: colorAppbarForeground,
            newsItem.isFav ? Icons.bookmark_added : Icons.bookmark_add,
          ),
        ),
        const SizedBox(width: 10),
        newsItem.isFav
            ? const BarTextButton(text: 'Unstar')
            : const BarTextButton(text: 'Star'),
      ],
    );
  }
}

class BarTextButton extends StatelessWidget {
  final String text;
  final double size;

  const BarTextButton({
    Key? key,
    required this.text,
    this.size = 17,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: size),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////

class BookmarkReadButton extends ConsumerWidget {
  const BookmarkReadButton({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(starredNotifierProvider);

    final newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Status stat;

            newsItem.status == Status.read
                ? stat = Status.unread
                : stat = Status.read;

            ref.read(starredNotifierProvider.notifier).toggleRead(
                  entryId,
                  stat,
                  context,
                );
          },
          child: Icon(
            size: 27,
            color: colorRed,
            newsItem.status == Status.unread
                ? Icons.circle
                : Icons.circle_outlined,
          ),
        ),
        const SizedBox(width: 10),
        newsItem.status == Status.unread
            ? const BarTextButton(text: 'Unread')
            : const BarTextButton(text: 'Read'),
      ],
    );
  }
}

class BookmarkStarredButton extends ConsumerWidget {
  const BookmarkStarredButton({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final isStarred = ref.watch(isStarredProvider);
    final newsNotifier = ref.watch(starredNotifierProvider);

    final newsItem = newsNotifier.firstWhere((e) => e.entryId == entryId);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () {
            ref.read(starredNotifierProvider.notifier).toggleFavStatus(
                  newsItem.entryId,
                  context,
                );
          },
          child: Icon(
            size: 27,
            color: colorAppbarForeground,
            newsItem.isFav ? Icons.bookmark_added : Icons.bookmark_add,
          ),
        ),
        const SizedBox(width: 10),
        newsItem.isFav
            ? const BarTextButton(text: 'Unstar')
            : const BarTextButton(text: 'Star'),
      ],
    );
  }
}
