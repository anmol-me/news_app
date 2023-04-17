import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExpansionWidget extends HookWidget {
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
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return GestureDetector(
      onLongPress: () {
        isExpanded.value = !isExpanded.value;
      },
      child: Column(
        children: [
          Container(
            child: topSection,
          ),
          Container(
            child: titleSection,
          ),
          if (isExpanded.value) onExpanded,
        ],
      ),
    );
  }
}
