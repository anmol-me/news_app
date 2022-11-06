import 'package:flutter/material.dart';

class Sizer extends StatelessWidget {
  final Widget child;
  final double? widthMobile;
  final double? widthTablet;
  final double? widthDesktopOrWeb;
  final int? setMobileWidth;
  final int? setStartTabletWidth;
  final int? setEndTabletWidth;
  final int? setDesktopOrWebWidth;

  const Sizer(
      {super.key,
      required this.child,
      this.widthMobile,
      this.widthTablet,
      this.widthDesktopOrWeb,
      this.setMobileWidth,
      this.setStartTabletWidth,
      this.setEndTabletWidth,
      this.setDesktopOrWebWidth});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double universalWidth() {
      final width = size.width;
      final mobileWidthSet = setMobileWidth ?? 650;
      final tabletStartWidthSet = setStartTabletWidth ?? 650;
      final tabletEndWidthSet = setEndTabletWidth ?? 1100;
      final desktopOrWebWidthSet = setDesktopOrWebWidth ?? 1100;

      final isMobile = width < mobileWidthSet;
      final isTablet =
          width < tabletEndWidthSet && width >= tabletStartWidthSet;
      final isDesktopOrWeb = width >= desktopOrWebWidthSet;

      if (isMobile) {
        return widthMobile != null ? width * widthMobile! : width;
      } else if (isTablet) {
        return widthTablet != null ? width * widthTablet! : width * 0.40;
      } else if (isDesktopOrWeb) {
        return widthDesktopOrWeb != null ? width * widthDesktopOrWeb! : width * 0.20;
      }
      return width;
    }

    return SizedBox(
      width: universalWidth(),
      child: child,
    );
  }
}
