import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../common/enums.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({
    super.key,
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        height: MediaQuery.of(context).size.height *
            0.30,
        width: MediaQuery.of(context).size.width *
            0.90,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: colorRed,
            strokeWidth: 1,
          ),
        ),
        errorWidget: (context, url, error) =>
            Image.network(
              ErrorString.image.value,
              height: 90,
              width: 120,
              fit: BoxFit.cover,
            ),
      ),
    );
  }
}