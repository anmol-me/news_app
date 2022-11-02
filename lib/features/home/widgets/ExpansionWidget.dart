import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpansionWidget extends ConsumerStatefulWidget {
  final Widget topSection;
  final Widget titleSection;
  final Widget onExpanded;

  const ExpansionWidget({
    super.key,
    required this.titleSection,
    required this.topSection,
    required this.onExpanded,
  });

  @override
  ConsumerState createState() => _ExpansionWidgetState();
}

class _ExpansionWidgetState extends ConsumerState<ExpansionWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() => isExpanded = !isExpanded);
      },
      child: Column(
        children: [
          Container(
            child: widget.topSection,
          ),
          Container(
            child: widget.titleSection,
          ),
          if (isExpanded)
            widget.onExpanded,
        ],
      ),
    );
  }
}
