part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

final class GameXpEarned extends GameEvent {
  const GameXpEarned({required this.amount});

  final double amount;

  @override
  List<Object> get props => [amount];
}

final class GameOver extends GameEvent {
  const GameOver();
}

final class GameSectionCompleted extends GameEvent {
  const GameSectionCompleted({required this.sectionCount});

  final int sectionCount;

  @override
  List<Object> get props => [sectionCount];
}
