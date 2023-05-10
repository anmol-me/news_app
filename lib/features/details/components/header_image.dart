import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../common/enums.dart';
import '../../../common_widgets/common_widgets.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({
    super.key,
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double height;
    double width;

    if (size.width > 600) {
      height = size.height * 0.40;
      width = size.width * 0.70;
    } else {
      height = size.height * 0.30;
      width = size.width * 0.90;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          height: height,
          width: width,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularLoadingImage(),
          ),
          errorWidget: (context, url, error) => Image.asset(
            Constants.imageNotFoundUrl.value,
            height: 90,
            width: 120,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
