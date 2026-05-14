import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

class ZienaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool onDark;

  const ZienaLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(onDark?'assets/images/white_logo.png':'assets/images/main_logo.png', height: size * 0.65, width: size * 0.65)
      ),
    );
  }
}
