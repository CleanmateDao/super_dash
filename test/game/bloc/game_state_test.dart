import 'package:cleanmate_rush/game/bloc/game_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameState', () {
    test('initial xp is zero', () {
      expect(GameState.initial().xp, isZero);
    });

    test('copyWith updates xp', () {
      expect(
        GameState.initial().copyWith(xp: 0.015),
        const GameState(xp: 0.015, currentLevel: 1, currentSection: 0),
      );
    });

    test('copyWith updates currentLevel', () {
      expect(
        GameState.initial().copyWith(currentLevel: 2),
        const GameState(xp: 0, currentLevel: 2, currentSection: 0),
      );
    });

    test('copyWith updates currentSection', () {
      expect(
        GameState.initial().copyWith(currentSection: 3),
        const GameState(xp: 0, currentLevel: 1, currentSection: 3),
      );
    });
  });
}
