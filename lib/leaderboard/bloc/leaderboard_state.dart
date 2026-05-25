part of 'leaderboard_bloc.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState({this.weeksAgo = 0});

  final int weeksAgo;

  @override
  List<Object> get props => [weeksAgo];
}

final class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial({super.weeksAgo});
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading({super.weeksAgo});
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded({
    required this.entries,
    super.weeksAgo,
  });

  final List<LeaderboardEntryData> entries;

  @override
  List<Object> get props => [entries, weeksAgo];
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError({super.weeksAgo});
}
