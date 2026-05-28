import 'package:cleanmate_rush/analytics/analytics.dart';
import 'package:cleanmate_rush/score/bloc/score_bloc.dart';
import 'package:cleanmate_rush/score/routes/routes.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pops the score route and signals [GameView] to restart the run.
void completePlayAgainFlow(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop(ScoreFlowResult.playAgain);
}

/// Pops the score route and returns the player to locations.
void completeBackToLocationsFlow(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop(
    ScoreFlowResult.backToLocations,
  );
}

class ScorePage extends StatelessWidget {
  const ScorePage({
    required this.xp,
    super.key,
  });

  static PageRoute<ScoreFlowResult> route({required double xp}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: RushAnalyticsScreen.score),
      pageBuilder: (_, __, ___) => ScorePage(xp: xp),
    );
  }

  final double xp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScoreBloc(
        xp: xp,
      ),
      child: const ScoreView(),
    );
  }
}

class ScoreView extends StatelessWidget {
  const ScoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<ScoreState>(
      state: context.select((ScoreBloc bloc) => bloc.state),
      onGeneratePages: onGenerateScorePages,
      // Flow completion is handled by popping the score route from child pages.
    );
  }
}
