// ignore_for_file: prefer_const_constructors

import 'package:cleanmate_rush/audio/audio.dart';
import 'package:cleanmate_rush/game/cleanmate_rush_game.dart';
import 'package:cleanmate_rush/map_tester/map_tester.dart';
import 'package:cleanmate_rush/settings/settings_controller.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class _MockAudioController extends Mock implements AudioController {}

class _MockSettingsController extends Mock implements SettingsController {}

void main() {
  group('MapTesterView', () {
    late SettingsController settingsController;

    setUp(() {
      settingsController = _MockSettingsController();
      when(() => settingsController.muted).thenReturn(ValueNotifier(true));
      when(() => settingsController.musicOn).thenReturn(ValueNotifier(false));
      when(() => settingsController.soundsOn).thenReturn(ValueNotifier(false));
    });

    testWidgets('renders', (tester) async {
      await tester.pumpSubject(settingsController: settingsController);

      expect(find.byType(MapTesterView), findsOneWidget);
    });

    testWidgets('loads the game', (tester) async {
      tester.setViewSize();

      await tester.pumpSubject(settingsController: settingsController);

      await tester.tap(find.text('Load'));
      await tester.pump();

      expect(
        find.byType(GameWidget<CleanmateRushGame>),
        findsOneWidget,
      );
    });

    testWidgets('can unload the game', (tester) async {
      tester.setViewSize();

      await tester.pumpSubject(settingsController: settingsController);

      await tester.tap(find.text('Load'));
      await tester.pump();

      expect(
        find.byType(GameWidget<CleanmateRushGame>),
        findsOneWidget,
      );

      await tester.tap(find.text('Unload'));
      await tester.pump();

      expect(
        find.byType(GameWidget<CleanmateRushGame>),
        findsNothing,
      );
    });

    testWidgets('allows to reload a game', (tester) async {
      tester.setViewSize();

      await tester.pumpSubject(settingsController: settingsController);

      await tester.tap(find.text('Load'));
      await tester.pump();

      var widget = tester.widget<GameWidget<CleanmateRushGame>>(
        find.byType(GameWidget<CleanmateRushGame>),
      );

      final originalGame = widget.game;
      expect(originalGame, isNotNull);

      await tester.tap(find.text('Reload'));
      await tester.pumpAndSettle();

      widget = tester.widget<GameWidget<CleanmateRushGame>>(
        find.byType(GameWidget<CleanmateRushGame>),
      );

      final updatedGame = widget.game;
      expect(updatedGame, isNotNull);
      expect(updatedGame, isNot(originalGame));
    });
  });
}

extension on WidgetTester {
  Future<void> pumpSubject({
    AudioController? audioController,
    SettingsController? settingsController,
  }) async {
    await pumpApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
            value: audioController ?? _MockAudioController(),
          ),
          RepositoryProvider.value(
            value: settingsController ?? _MockSettingsController(),
          ),
        ],
        child: MapTesterView(
          timer: Future.value,
        ),
      ),
    );
  }
}
