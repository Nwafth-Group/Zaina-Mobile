import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/theme/theme.dart';

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
      this.assetPath, {
        super.key,
        this.size = 24,
        this.color = Colors.white,
        this.semanticLabel,
      });

  final String assetPath;
  final double size;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
      semanticsLabel: semanticLabel,
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon(
      this.icon, {
        super.key,
        this.size = 24,
        this.width = 1,
        this.color = ZienaColors.primary,
      });

  final List<List<dynamic>> icon;
  final double size;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: icon,
      color: color,
      size: size,
      strokeWidth: width,
    );
  }
}

class ImageAsset extends StatelessWidget {
  const ImageAsset(
      this.assetPath, {
        super.key,
        this.height = 30,
        this.width = 30,
        this.fit = BoxFit.contain,
      });

  final String assetPath;
  final double height;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
