import 'package:flutter/widgets.dart';

class XpIcon extends StatelessWidget {
  const XpIcon({
    this.size = 22,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/xp.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
