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
}
