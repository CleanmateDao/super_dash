// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:cleanmate_rush/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderboard_repository/leaderboard_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockLeaderboardRepository extends Mock
    implements LeaderboardRepository {}

class _FakeLeaderboardEntryData extends Fake implements LeaderboardEntryData {}

void main() {
  group('LeaderboardBloc', () {
    late LeaderboardRepository leaderboardRepository;
    late LeaderboardEntryData leaderboardEntryData;

    setUp(() {
      leaderboardRepository = _MockLeaderboardRepository();
      leaderboardEntryData = _FakeLeaderboardEntryData();
    });

    test(
      'default state is LeaderboardInitial',
      () => expect(
        LeaderboardBloc(leaderboardRepository: leaderboardRepository).state,
        isA<LeaderboardInitial>(),
      ),
    );

    blocTest<LeaderboardBloc, LeaderboardState>(
      'emits [LeaderboardLoading, LeaderboardLoaded] '
      'when LeaderboardTop10Requested is added and repository returns data',
      setUp: () {
        when(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 0),
        ).thenAnswer(
          (_) async => [leaderboardEntryData],
        );
      },
      build: () => LeaderboardBloc(
        leaderboardRepository: leaderboardRepository,
      ),
      act: (bloc) => bloc.add(LeaderboardTop10Requested()),
      expect: () => [
        LeaderboardLoading(weeksAgo: 0),
        LeaderboardLoaded(entries: [leaderboardEntryData], weeksAgo: 0),
      ],
    );

    blocTest<LeaderboardBloc, LeaderboardState>(
      'emits [LeaderboardLoading, LeaderboardError] '
      'when LeaderboardTop10Requested is added and repository fails',
      setUp: () {
        when(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 0),
        ).thenThrow(Exception());
      },
      build: () => LeaderboardBloc(
        leaderboardRepository: leaderboardRepository,
      ),
      act: (bloc) => bloc.add(LeaderboardTop10Requested()),
      expect: () => [
        LeaderboardLoading(weeksAgo: 0),
        LeaderboardError(weeksAgo: 0),
      ],
    );

    blocTest<LeaderboardBloc, LeaderboardState>(
      'loads an older week when LeaderboardNextWeekRequested is added',
      setUp: () {
        when(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 0),
        ).thenAnswer((_) async => [leaderboardEntryData]);
        when(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 1),
        ).thenAnswer((_) async => [leaderboardEntryData]);
      },
      build: () => LeaderboardBloc(
        leaderboardRepository: leaderboardRepository,
      ),
      seed: () => LeaderboardLoaded(
        entries: [leaderboardEntryData],
        weeksAgo: 0,
      ),
      act: (bloc) => bloc.add(const LeaderboardNextWeekRequested()),
      expect: () => [
        LeaderboardLoading(weeksAgo: 1),
        LeaderboardLoaded(entries: [leaderboardEntryData], weeksAgo: 1),
      ],
      verify: (_) {
        verify(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 1),
        ).called(1);
      },
    );

    blocTest<LeaderboardBloc, LeaderboardState>(
      'loads a more recent week when LeaderboardPreviousWeekRequested is added',
      setUp: () {
        when(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 0),
        ).thenAnswer((_) async => [leaderboardEntryData]);
      },
      build: () => LeaderboardBloc(
        leaderboardRepository: leaderboardRepository,
      ),
      seed: () => LeaderboardLoaded(
        entries: [leaderboardEntryData],
        weeksAgo: 1,
      ),
      act: (bloc) => bloc.add(const LeaderboardPreviousWeekRequested()),
      expect: () => [
        LeaderboardLoading(weeksAgo: 0),
        LeaderboardLoaded(entries: [leaderboardEntryData], weeksAgo: 0),
      ],
      verify: (_) {
        verify(
          () => leaderboardRepository.fetchWeeklyLeaderboard(weeksAgo: 0),
        ).called(1);
      },
    );
  });

  group('formatLeaderboardWeekLabel', () {
    test('formats current and prior weeks', () {
      expect(formatLeaderboardWeekLabel(0), 'This week');
      expect(formatLeaderboardWeekLabel(1), '1 week ago');
      expect(formatLeaderboardWeekLabel(3), '3 weeks ago');
    });
  });
}
