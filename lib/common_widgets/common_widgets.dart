import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:news_app/models/news.dart';

import '../features/authentication/repository/user_preferences.dart';
import '../features/category/repository/category_repo.dart';
import '../features/details/components/providers.dart';
import '../features/home/providers/home_providers.dart';
import '../features/search/repository/search_repo.dart';
import '../common/constants.dart';
import '../common/enums.dart';

class LinearLoader extends StatelessWidget {
  const LinearLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: colorRed,
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

class CircularLoadingImage extends StatelessWidget {
  final Color? color;

  const CircularLoadingImage({
    super.key,
    this.color = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: colorRed,
      strokeWidth: 1,
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
  required BuildContext context,
  required String text,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

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
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 5),
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Text(text),
    ),
  );
}

class ReadButton extends ConsumerWidget {
  final int entryId;
  final String screenName;

  const ReadButton({
    super.key,
    required this.entryId,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);
    final categoryNotifier = ref.watch(categoryNotifierProvider);
    final searchNotifier = ref.watch(searchNotifierProvider);

    final newsController = ref.watch(homeFeedProvider.notifier);
    final categoryController = ref.watch(categoryNotifierProvider.notifier);
    final searchController = ref.watch(searchNotifierProvider.notifier);

    News newsItem;

    if (screenName == 'search') {
      newsItem = searchNotifier.firstWhere(
        (e) => e.entryId == entryId,
      );
    } else if (screenName == 'category') {
      newsItem = categoryNotifier.firstWhere(
        (e) => e.entryId == entryId,
      );
    } else {
      newsItem = newsNotifier.firstWhere(
        (e) => e.entryId == entryId,
      );
    }

    return InkWell(
      onTap: () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        if (isDemoPref) {
          return;
        }

        Status stat;

        newsItem.status == Status.read
            ? stat = Status.unread
            : stat = Status.read;

        if (screenName == 'search') {
          searchController.toggleRead(
            entryId,
            stat,
            context,
          );
        } else if (screenName == 'category') {
          categoryController.toggleRead(
            entryId,
            stat,
            context,
          );
        } else {
          newsController.toggleRead(
            entryId,
            stat,
            context,
          );
        }
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
              ? const TextBar(text: 'Unread')
              : const TextBar(text: 'Read'),
        ],
      ),
    );
  }
}

class StarredButton extends ConsumerWidget {
  const StarredButton({
    super.key,
    required this.entryId,
    required this.screenName,
  });

  final int entryId;
  final String screenName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsNotifier = ref.watch(homeFeedProvider);
    final categoryNotifier = ref.watch(categoryNotifierProvider);
    final searchNotifier = ref.watch(searchNotifierProvider);

    final newsController = ref.watch(homeFeedProvider.notifier);
    final categoryController = ref.watch(categoryNotifierProvider.notifier);
    final searchController = ref.watch(searchNotifierProvider.notifier);

    News newsItem;

    if (screenName == 'search') {
      newsItem = searchNotifier.firstWhere(
        (e) => e.entryId == entryId,
      );
    } else if (screenName == 'category') {
      newsItem = categoryNotifier.firstWhere(
        (e) => e.entryId == entryId,
      );
    } else {
      newsItem = newsNotifier.firstWhere(
        (e) => e.entryId == entryId,
      );
    }

    return InkWell(
      onTap: () {
        final isDemoPref = ref.read(userPrefsProvider).getIsDemo() ?? false;
        if (isDemoPref) {
          return;
        }

        if (screenName == 'search') {
          searchController.toggleFavStatus(
            newsItem.entryId,
            context,
          );
        } else if (screenName == 'category') {
          categoryController.toggleFavStatus(
            newsItem.entryId,
            context,
          );
        } else {
          newsController.toggleFavStatus(
            newsItem.entryId,
            context,
          );
        }
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
              ? const TextBar(text: 'Unstar')
              : const TextBar(text: 'Star'),
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
          const TextBar(text: 'Open link'),
        ],
      ),
    );
  }
}

class TextBar extends StatelessWidget {
  final String text;
  final double size;
  final Color textColor;

  const TextBar({
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

class TextBarButton extends StatelessWidget {
  final String text;
  final double size;
  final Color textColor;
  final VoidCallback onTap;

  const TextBarButton({
    super.key,
    required this.text,
    this.size = 17,
    this.textColor = Colors.black87,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          color: textColor,
        ),
      ),
    );
  }
}
