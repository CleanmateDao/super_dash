import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class RushSession {
  const RushSession({
    required this.walletAddress,
    required this.token,
  });

  final String walletAddress;
  final String token;
}

class UserSessionRepository {
  const UserSessionRepository();

  static const _walletAddressKey = 'cleanmate_wallet_address';
  static const _rushTokenKey = 'cleanmate_rush_token';
  static final _sessionController = StreamController<RushSession?>.broadcast();

  Stream<RushSession?> get sessionChanges => _sessionController.stream;

  Future<String?> readWalletAddress() async {
    return (await readSession())?.walletAddress;
  }

  Future<RushSession?> readSession() async {
    final preferences = await SharedPreferences.getInstance();
    final walletAddress = preferences.getString(_walletAddressKey);
    final token = preferences.getString(_rushTokenKey);
    if (walletAddress == null ||
        walletAddress.trim().isEmpty ||
        token == null ||
        token.trim().isEmpty) {
      return null;
    }
    return RushSession(walletAddress: walletAddress, token: token);
  }

  Future<void> linkWalletAddress(String walletAddress) async {
    await saveRushSession(RushSession(walletAddress: walletAddress, token: ''));
  }

  Future<void> saveRushSession(RushSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_walletAddressKey, session.walletAddress);
    await preferences.setString(_rushTokenKey, session.token);
    _sessionController.add(session);
  }

  Future<void> clearWalletAddress() async {
    await clearSession();
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_walletAddressKey);
    await preferences.remove(_rushTokenKey);
    _sessionController.add(null);
  }
}
