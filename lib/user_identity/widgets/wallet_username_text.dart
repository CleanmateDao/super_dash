import 'package:flutter/material.dart';

class WalletUsernameText extends StatelessWidget {
  const WalletUsernameText({
    required this.walletAddress,
    this.profileName,
    this.domainName,
    this.style,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String walletAddress;
  final String? profileName;
  final String? domainName;
  final TextStyle? style;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  static String resolve({
    required String walletAddress,
    String? profileName,
    String? domainName,
  }) {
    final cleanProfileName = profileName?.trim();
    if (cleanProfileName != null && cleanProfileName.isNotEmpty) {
      return cleanProfileName;
    }

    final cleanDomainName = domainName?.trim();
    if (cleanDomainName != null && cleanDomainName.isNotEmpty) {
      return cleanDomainName;
    }

    return formatWalletAddress(walletAddress);
  }

  static String formatWalletAddress(String walletAddress) {
    if (walletAddress.length <= 12) {
      return walletAddress;
    }

    return '${walletAddress.substring(0, 6)}...'
        '${walletAddress.substring(walletAddress.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      resolve(
        walletAddress: walletAddress,
        profileName: profileName,
        domainName: domainName,
      ),
      textAlign: textAlign,
      overflow: overflow,
      style: style,
    );
  }
}
