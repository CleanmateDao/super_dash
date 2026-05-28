// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGameBloc extends MockBloc<GameEvent, GameState>
    implements GameBloc {}

class _MockAudioController extends Mock implements AudioController {}

class _MockRushAnalytics extends Mock implements RushAnalytics {}

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
    }) {
      return CleanmateRushGame(
        gameBloc: gameBloc,
        audioController: audioController,
        rushAnalytics: _MockRushAnalytics(),
        gameplayXpPoster: gameplayXpPoster,
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

    late Completer<void> xpPosted;
    late List<double> endedRunPostedXp;

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
