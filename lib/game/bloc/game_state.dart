part of 'game_bloc.dart';

class GameState extends Equatable {
  const GameState({
    required this.xp,
    required this.currentLevel,
    required this.currentSection,
  });

  const GameState.initial()
      : xp = 0,
        currentLevel = 1,
        currentSection = 0;

  final double xp;
  final int currentLevel;
  final int currentSection;

  GameState copyWith({
    double? xp,
    int? currentLevel,
    int? currentSection,
  }) {
    return GameState(
      xp: xp ?? this.xp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentSection: currentSection ?? this.currentSection,
    );
  }

  @override
  List<Object?> get props => [xp, currentLevel, currentSection];
}
