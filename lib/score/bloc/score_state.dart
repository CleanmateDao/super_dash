part of 'score_bloc.dart';

enum ScoreStatus {
  gameOver,
  leaderboard,
}

class ScoreState extends Equatable {
  const ScoreState({
    this.status = ScoreStatus.gameOver,
    this.playAgainRequested = false,
  });

  final ScoreStatus status;
  final bool playAgainRequested;

  ScoreState copyWith({
    ScoreStatus? status,
    bool? playAgainRequested,
  }) {
    return ScoreState(
      status: status ?? this.status,
      playAgainRequested: playAgainRequested ?? this.playAgainRequested,
    );
  }

  @override
  List<Object> get props => [status, playAgainRequested];
}
