// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:cleanmate_rush/game/bloc/game_bloc.dart';
import 'package:cleanmate_rush/game/xp_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameBloc', () {
    blocTest<GameBloc, GameState>(
      'emits GameState initial when GameOver is added',
      build: GameBloc.new,
      seed: () => const GameState(
        xp: 0.015,
        currentLevel: 2,
        currentSection: 2,
      ),
      act: (bloc) => bloc.add(GameOver()),
      expect: () => const [GameState.initial()],
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
