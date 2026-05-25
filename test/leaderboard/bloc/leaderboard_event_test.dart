// ignore_for_file: prefer_const_constructors

import 'package:cleanmate_rush/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LeaderboardTop10Requested', () {
    test(
      'supports value equality',
      () => expect(
        LeaderboardTop10Requested(),
        LeaderboardTop10Requested(),
      ),
    );
  });

  group('LeaderboardWeeklyRequested', () {
    test(
      'supports value equality',
      () => expect(
        const LeaderboardWeeklyRequested(weeksAgo: 2),
        const LeaderboardWeeklyRequested(weeksAgo: 2),
      ),
    );
  });

  group('LeaderboardPreviousWeekRequested', () {
    test(
      'supports value equality',
      () => expect(
        const LeaderboardPreviousWeekRequested(),
        const LeaderboardPreviousWeekRequested(),
      ),
    );
  });

  group('LeaderboardNextWeekRequested', () {
    test(
      'supports value equality',
      () => expect(
        const LeaderboardNextWeekRequested(),
        const LeaderboardNextWeekRequested(),
      ),
    );
  });
}
