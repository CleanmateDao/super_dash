// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:cleanmate_rush/game/bloc/game_bloc.dart';
import 'package:cleanmate_rush/game/xp_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameBloc', () {
    blocTest<GameBloc, GameState>(
      'clears xp and resets section when GameOver is added',
      build: GameBloc.new,
      seed: () => const GameState(
        xp: 0.015,
        currentLevel: 2,
        currentSection: 2,
      ),
      act: (bloc) => bloc.add(GameOver()),
      expect: () => const [
        GameState(
          xp: 0,
          currentLevel: 2,
          currentSection: 0,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'advances level when the last section is completed',
      build: GameBloc.new,
      seed: () => const GameState(
        currentLevel: 1,
        currentSection: 2,
      ),
      act: (bloc) => bloc.add(const GameSectionCompleted(sectionCount: 3)),
      expect: () => const [
        GameState(
          currentLevel: 2,
          currentSection: 0,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'emits GameState with xp increased when GameXpEarned is added',
      build: GameBloc.new,
      seed: () => const GameState.initial().copyWith(xp: 0.005),
      act: (bloc) => bloc.add(const GameXpEarned(amount: xpPerValidHit)),
      expect: () => [const GameState.initial().copyWith(xp: 0.01)],
    );
  });
}
