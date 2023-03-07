import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/common_widgets/disabled_button_widgets.dart';

Widget buildTopBar(
  bool isLoadingPage,
  bool canGoToPreviousPage,
  void Function() previous,
  bool canGoToNextPage,
  void Function() next,
  WidgetRef ref,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isLoadingPage
                ? const DisabledPreviousButton()
                : InkWell(
                    onTap: () {
                      canGoToPreviousPage ? previous() : null;
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: canGoToPreviousPage
                              ? Colors.redAccent
                              : Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 17,
                            color: canGoToPreviousPage
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
            isLoadingPage
                ? const DisabledMoreButton()
                : InkWell(
                    onTap: () => canGoToNextPage ? next() : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'More',
                          style: TextStyle(
                            fontSize: 17,
                            color: canGoToNextPage
                                ? Colors.redAccent[200]
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: canGoToNextPage
                              ? Colors.redAccent[200]
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    ],
  );
}
