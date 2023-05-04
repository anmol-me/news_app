import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String name;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Animation<double>? opacity;

  const AppImage(
    this.name, {
    super.key,
    this.onTap,
    this.width = 230,
    this.height = 230,
    this.fit = BoxFit.contain,
    this.opacity = const AlwaysStoppedAnimation(0.9),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        name,
        width: width,
        height: height,
        fit: fit,
        opacity: opacity,
      ),
    );
  }
}
