part of 'score_bloc.dart';

enum ScoreFlowResult {
  dismissed,
  playAgain,
  backToLocations,
}

enum ScoreStatus {
  gameOver,
  leaderboard,
}

class ScoreState extends Equatable {
  const ScoreState({
    this.status = ScoreStatus.gameOver,
    this.playAgainRequested = false,
    this.backToLocationsRequested = false,
  });

  final ScoreStatus status;
  final bool playAgainRequested;
  final bool backToLocationsRequested;

  ScoreState copyWith({
    ScoreStatus? status,
    bool? playAgainRequested,
    bool? backToLocationsRequested,
  }) {
    return ScoreState(
      status: status ?? this.status,
      playAgainRequested: playAgainRequested ?? this.playAgainRequested,
      backToLocationsRequested:
          backToLocationsRequested ?? this.backToLocationsRequested,
    );
  }

  ScoreFlowResult get flowResult {
    if (playAgainRequested) {
      return ScoreFlowResult.playAgain;
    }
    if (backToLocationsRequested) {
      return ScoreFlowResult.backToLocations;
    }
    return ScoreFlowResult.dismissed;
  }

  @override
  List<Object> get props =>
      [status, playAgainRequested, backToLocationsRequested];
}
