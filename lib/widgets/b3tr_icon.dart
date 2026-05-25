import 'package:flutter/widgets.dart';

class B3trIcon extends StatelessWidget {
  const B3trIcon({
    this.size = 16,
    super.key,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/b3tr.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
