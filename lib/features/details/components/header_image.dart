import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../common/common_widgets.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({
    super.key,
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        height: size.height * 0.30,
        width: size.width * 0.90,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularLoadingImage(),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/notfound.png',
          height: 90,
          width: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
