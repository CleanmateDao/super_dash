import 'dart:async';

import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class RushRealtimeService {
  RushRealtimeService({
    required UserSessionRepository sessionRepository,
    required RushApiClient apiClient,
  })  : _sessionRepository = sessionRepository,
        _apiClient = apiClient;

  final UserSessionRepository _sessionRepository;
  final RushApiClient _apiClient;
  final _xpController = StreamController<RushXpAwardResult>.broadcast();

  StreamSubscription<RushSession?>? _sessionSubscription;
  io.Socket? _socket;

  Stream<RushXpAwardResult> get xpUpdates => _xpController.stream;

  void notifyXpAwarded(RushXpAwardResult result) {
    if (!_xpController.isClosed) {
      _xpController.add(result);
    }
  }

  Future<void> start() async {
    _sessionSubscription ??= _sessionRepository.sessionChanges.listen(_connect);
    await _connect(await _sessionRepository.readSession());
  }

  Future<void> stop() async {
    await _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _disconnect();
  }

  void dispose() {
    unawaited(stop());
    _xpController.close();
  }

  Future<void> _connect(RushSession? session) async {
    _disconnect();
    if (session == null) {
      return;
    }

    final socket = io.io(
      '${_apiClient.socketOrigin}/rush',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': session.token})
          .disableAutoConnect()
          .build(),
    );
    _socket = socket
      ..on('rush:xp:updated', _handleXpUpdated)
      ..on('rush:session:revoked', (_) {
        unawaited(_sessionRepository.clearSession());
      })
      ..onDisconnect((_) {});
    socket.connect();
  }

  void _disconnect() {
    final socket = _socket;
    _socket = null;
    socket
      ?..clearListeners()
      ..disconnect()
      ..dispose();
  }

  void _handleXpUpdated(dynamic payload) {
    if (payload is! Map) {
      return;
    }
    final delta = payload['delta'];
    final xpTotal = payload['xpTotal'];
    final weekXp = payload['weekXp'];
    if (delta is! num || xpTotal is! num || weekXp is! num) {
      return;
    }
    _xpController.add(
      RushXpAwardResult(
        applied: delta != 0,
        delta: delta,
        xpTotal: xpTotal,
        weekXp: weekXp,
      ),
    );
  }
}
