import 'package:cleanmate_rush/score/bloc/score_bloc.dart';
import 'package:cleanmate_rush/score/routes/routes.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScorePage extends StatelessWidget {
  const ScorePage({
    required this.xp,
    super.key,
  });

  static PageRoute<void> route({required double xp}) {
    return PageRouteBuilder(
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
    );
  }
}
