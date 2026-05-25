import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/game/bloc/game_bloc.dart';
import 'package:cleanmate_rush/utils/utils.dart';
import 'package:cleanmate_rush/widgets/xp_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class XpLabel extends StatelessWidget {
  const XpLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.appTheme;
    final xp = context.select(
      (GameBloc bloc) => bloc.state.xp,
    );

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: TraslucentBackground(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: tokens.border,
          ),
          gradient: tokens.cardGradient.colors,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const XpIcon(size: 16),
                const SizedBox(width: 8),
                Text(
                  formatXp(xp),
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.foreground,
                    fontWeight: AppFontWeights.semibold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
