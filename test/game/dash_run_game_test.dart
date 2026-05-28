// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:cleanmate_rush/user_session/user_session.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGameBloc extends MockBloc<GameEvent, GameState>
    implements GameBloc {}

class _MockAudioController extends Mock implements AudioController {}

class _MockUserSessionRepository extends Mock
    implements UserSessionRepository {}

class _MockRushApiClient extends Mock implements RushApiClient {}

class _MockRushRealtimeService extends Mock implements RushRealtimeService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CleanmateRushGame', () {
    late GameBloc gameBloc;
    late AudioController audioController;

    setUp(() {
      gameBloc = _MockGameBloc();
      audioController = _MockAudioController();

      when(() => gameBloc.state).thenReturn(const GameState.initial());
    });

    CleanmateRushGame createGame({
      GameplayXpPoster? gameplayXpPoster,
      void Function(double xp)? onRunEnded,
      UserSessionRepository? sessionRepository,
      RushApiClient? apiClient,
      RushRealtimeService? realtimeService,
    }) {
      return CleanmateRushGame(
        gameBloc: gameBloc,
        audioController: audioController,
        rushAnalytics: RushAnalytics.noop(),
        gameplayXpPoster: gameplayXpPoster,
        sessionRepository: sessionRepository,
        apiClient: apiClient,
        realtimeService: realtimeService,
        onRunEnded: onRunEnded,
      );
    }

    final flameTester = FlameTester(createGame);

    flameTester.testGameWidget(
      'starts with xp 0',
      setUp: (game, tester) async {
        when(() => game.gameBloc.state).thenReturn(const GameState.initial());
        await game.ready();
      },
      verify: (game, tester) async => expect(
        game.gameBloc.state.xp,
        isZero,
      ),
    );

    flameTester.testGameWidget(
      'starts with player',
      setUp: (game, tester) async {
        await game.ready();
      },
      verify: (game, tester) async => expect(
        game.world.descendants().whereType<Player>(),
        isNotNull,
      ),
    );

    flameTester.testGameWidget(
      'starts with an input',
      setUp: (game, tester) async {
        await game.ready();
      },
      verify: (game, tester) async => expect(
        game.descendants().whereType<KeyboardListenerComponent>(),
        isNotNull,
      ),
    );

    testWithGame(
      'starts with correct amount of items',
      createGame,
      (game) async {
        await game.ready();
        expect(
          game.leapMap.children.whereType<Item>().length,
          equals(33),
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
      skip: true, // TODO(all): This test is flaky, skipping it for now
    );

    testWithGame(
      'starts with 0 enemies spawned',
      createGame,
      (game) async {
        await game.ready();
        expect(
          game.leapMap.children.whereType<Enemy>().length,
          isZero,
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
      skip: true, // TODO(all): This test is flaky, skipping it for now
    );

    test('posts earned xp when the run is quit', () async {
      final postedXp = <double>[];
      when(() => gameBloc.state).thenReturn(
        const GameState.initial().copyWith(xp: 12.5),
      );
      final game = createGame(
        gameplayXpPoster: (xp) async => postedXp.add(xp),
      );

      await game.quitRun();
      await game.quitRun();

      expect(postedXp, equals([12.5]));
      verify(() => gameBloc.add(const GameOver())).called(1);
    });

    test('uses injected backend services to post earned xp', () async {
      const session = RushSession(walletAddress: '0x123', token: 'token');
      const awardResult = RushXpAwardResult(
        applied: true,
        delta: 12.5,
        xpTotal: 100,
        weekXp: 12.5,
      );
      final sessionRepository = _MockUserSessionRepository();
      final apiClient = _MockRushApiClient();
      final realtimeService = _MockRushRealtimeService();
      when(() => gameBloc.state).thenReturn(
        const GameState.initial().copyWith(xp: 12.5),
      );
      when(() => sessionRepository.readSession())
          .thenAnswer((_) async => session);
      when(
        () => apiClient.postGameplayXp(
          token: any(named: 'token'),
          amount: any(named: 'amount'),
          runId: any(named: 'runId'),
        ),
      ).thenAnswer((_) async => awardResult);
      final game = createGame(
        sessionRepository: sessionRepository,
        apiClient: apiClient,
        realtimeService: realtimeService,
      );

      await game.quitRun();

      verify(
        () => apiClient.postGameplayXp(
          token: session.token,
          amount: 12.5,
          runId: any(named: 'runId'),
        ),
      ).called(1);
      verify(() => realtimeService.notifyXpAwarded(awardResult)).called(1);
    });

    late Completer<void> xpPosted;
    late List<double> endedRunPostedXp;

    testWithGame(
      'uses injected backend services to post earned xp when the run ends',
      () {
        const session = RushSession(walletAddress: '0x123', token: 'token');
        const awardResult = RushXpAwardResult(
          applied: true,
          delta: 7.25,
          xpTotal: 100,
          weekXp: 7.25,
        );
        xpPosted = Completer<void>();
        final sessionRepository = _MockUserSessionRepository();
        final apiClient = _MockRushApiClient();
        final realtimeService = _MockRushRealtimeService();
        when(() => gameBloc.state).thenReturn(
          const GameState.initial().copyWith(xp: 7.25),
        );
        when(() => sessionRepository.readSession())
            .thenAnswer((_) async => session);
        when(
          () => apiClient.postGameplayXp(
            token: any(named: 'token'),
            amount: any(named: 'amount'),
            runId: any(named: 'runId'),
          ),
        ).thenAnswer((invocation) async {
          expect(invocation.namedArguments[#token], session.token);
          expect(invocation.namedArguments[#amount], 7.25);
          xpPosted.complete();
          return awardResult;
        });
        return createGame(
          sessionRepository: sessionRepository,
          apiClient: apiClient,
          realtimeService: realtimeService,
          onRunEnded: (_) {},
        );
      },
      (game) async {
        await game.ready();

        game.gameOver();

        await xpPosted.future.timeout(const Duration(seconds: 5));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    testWithGame(
      'posts earned xp when the run ends',
      () {
        xpPosted = Completer<void>();
        endedRunPostedXp = [];
        when(() => gameBloc.state).thenReturn(
          const GameState.initial().copyWith(xp: 7.25),
        );
        return createGame(
          gameplayXpPoster: (xp) async {
            endedRunPostedXp.add(xp);
            xpPosted.complete();
          },
          onRunEnded: (_) {},
        );
      },
      (game) async {
        await game.ready();

        game.gameOver();
        game.gameOver();

        await xpPosted.future.timeout(const Duration(seconds: 5));
        await Future<void>.delayed(Duration.zero);
        expect(endedRunPostedXp, equals([7.25]));
        verify(() => gameBloc.add(const GameOver())).called(1);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
