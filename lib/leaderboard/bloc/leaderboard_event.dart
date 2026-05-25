part of 'leaderboard_bloc.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class LeaderboardTop10Requested extends LeaderboardEvent {
  const LeaderboardTop10Requested();
}

class LeaderboardWeeklyRequested extends LeaderboardEvent {
  const LeaderboardWeeklyRequested({required this.weeksAgo});

  final int weeksAgo;

  @override
  List<Object> get props => [weeksAgo];
}

class LeaderboardPreviousWeekRequested extends LeaderboardEvent {
  const LeaderboardPreviousWeekRequested();
}

class LeaderboardNextWeekRequested extends LeaderboardEvent {
  const LeaderboardNextWeekRequested();
}
