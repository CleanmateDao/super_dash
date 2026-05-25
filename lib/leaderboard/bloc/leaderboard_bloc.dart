import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

const leaderboardMaxWeeksAgo = 52;

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({
    required LeaderboardRepository leaderboardRepository,
  })  : _leaderboardRepository = leaderboardRepository,
        super(const LeaderboardInitial()) {
    on<LeaderboardTop10Requested>(_onLeaderboardTop10Requested);
    on<LeaderboardWeeklyRequested>(_onLeaderboardWeeklyRequested);
    on<LeaderboardPreviousWeekRequested>(_onLeaderboardPreviousWeekRequested);
    on<LeaderboardNextWeekRequested>(_onLeaderboardNextWeekRequested);
  }

  final LeaderboardRepository _leaderboardRepository;

  Future<void> _onLeaderboardTop10Requested(
    LeaderboardTop10Requested event,
    Emitter<LeaderboardState> emit,
  ) {
    return _fetchWeeklyLeaderboard(weeksAgo: 0, emit: emit);
  }

  Future<void> _onLeaderboardWeeklyRequested(
    LeaderboardWeeklyRequested event,
    Emitter<LeaderboardState> emit,
  ) {
    return _fetchWeeklyLeaderboard(weeksAgo: event.weeksAgo, emit: emit);
  }

  Future<void> _onLeaderboardPreviousWeekRequested(
    LeaderboardPreviousWeekRequested event,
    Emitter<LeaderboardState> emit,
  ) {
    final weeksAgo = (state.weeksAgo - 1).clamp(0, leaderboardMaxWeeksAgo);
    if (weeksAgo == state.weeksAgo) {
      return Future<void>.value();
    }
    return _fetchWeeklyLeaderboard(weeksAgo: weeksAgo, emit: emit);
  }

  Future<void> _onLeaderboardNextWeekRequested(
    LeaderboardNextWeekRequested event,
    Emitter<LeaderboardState> emit,
  ) {
    final weeksAgo = (state.weeksAgo + 1).clamp(0, leaderboardMaxWeeksAgo);
    if (weeksAgo == state.weeksAgo) {
      return Future<void>.value();
    }
    return _fetchWeeklyLeaderboard(weeksAgo: weeksAgo, emit: emit);
  }

  Future<void> _fetchWeeklyLeaderboard({
    required int weeksAgo,
    required Emitter<LeaderboardState> emit,
  }) async {
    final safeWeeksAgo = weeksAgo.clamp(0, leaderboardMaxWeeksAgo);

    emit(LeaderboardLoading(weeksAgo: safeWeeksAgo));
    try {
      final leaderboard = await _leaderboardRepository.fetchWeeklyLeaderboard(
        weeksAgo: safeWeeksAgo,
      );
      emit(
        LeaderboardLoaded(
          entries: leaderboard,
          weeksAgo: safeWeeksAgo,
        ),
      );
    } catch (_) {
      emit(LeaderboardError(weeksAgo: safeWeeksAgo));
    }
  }
}

String formatLeaderboardWeekLabel(int weeksAgo) {
  if (weeksAgo == 0) {
    return 'This week';
  }
  if (weeksAgo == 1) {
    return '1 week ago';
  }
  return '$weeksAgo weeks ago';
}
