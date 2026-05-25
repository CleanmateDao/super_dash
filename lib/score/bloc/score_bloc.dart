import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'score_event.dart';
part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  ScoreBloc({
    required this.xp,
  }) : super(const ScoreState()) {
    on<ScoreLeaderboardRequested>(_onScoreLeaderboardRequested);
  }

  final double xp;

  void _onScoreLeaderboardRequested(
    ScoreLeaderboardRequested event,
    Emitter<ScoreState> emit,
  ) {
    emit(
      state.copyWith(
        status: ScoreStatus.leaderboard,
      ),
    );
  }
}
