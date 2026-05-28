import 'package:flutter/material.dart';

class WalletAvatar extends StatelessWidget {
  const WalletAvatar({
    required this.walletAddress,
    this.imageUrl,
    this.size = 36,
    super.key,
  });

  final String walletAddress;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl?.trim();
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: cleanImageUrl == null || cleanImageUrl.isEmpty
            ? _GeneratedAvatar(walletAddress: walletAddress)
            : Image.network(
                cleanImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _GeneratedAvatar(walletAddress: walletAddress);
                },
              ),
      ),
    );
  }
}

class _GeneratedAvatar extends StatelessWidget {
  const _GeneratedAvatar({required this.walletAddress});

  final String walletAddress;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(walletAddress);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          color: Colors.white.withValues(alpha: .9),
          size: 22,
        ),
      ),
    );
  }

  List<Color> _colorsFor(String value) {
    final hash = value.codeUnits.fold<int>(0, (hash, unit) => hash + unit);
    final hue = (hash * 37) % 360;
    return [
      HSLColor.fromAHSL(1, hue.toDouble(), .72, .45).toColor(),
      HSLColor.fromAHSL(1, ((hue + 48) % 360).toDouble(), .72, .34).toColor(),
    ];
  }
}
