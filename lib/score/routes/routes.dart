import 'package:cleanmate_rush/leaderboard/leaderboard.dart';
import 'package:cleanmate_rush/score/game_over/game_over.dart';
import 'package:cleanmate_rush/score/score.dart';
import 'package:flutter/material.dart';

List<Page<void>> onGenerateScorePages(
  ScoreState state,
  List<Page<void>> pages,
) {
  return switch (state.status) {
    ScoreStatus.gameOver => [GameOverPage.page()],
    ScoreStatus.leaderboard => [LeaderboardPage.page()],
  };
}
