import 'package:app_ui/app_ui.dart';
import 'package:cleanmate_rush/game_intro/game_instructions/game_instructions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameInstructionNavigationControls extends StatelessWidget {
  const GameInstructionNavigationControls({
    required this.pageController,
    super.key,
  });

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final currentStep = context.select(
      (GameInstructionsCubit cubit) => cubit.state.currentStep,
    );
    final isFirstStep = currentStep == GameInstructionsStep.values.first;
    final isLastStep = currentStep == GameInstructionsStep.values.last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final step in GameInstructionsStep.values)
              _PageIndicator(step: step),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: isFirstStep ? 0.4 : 1,
              child: GameIconButton(
                icon: Icons.arrow_back_outlined,
                onPressed: isFirstStep
                    ? null
                    : () => pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                        ),
              ),
            ),
            const SizedBox(width: 24),
            GameIconButton(
              icon: isLastStep
                  ? Icons.check_outlined
                  : Icons.arrow_forward_outlined,
              onPressed: isLastStep
                  ? Navigator.of(context).pop
                  : () => pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.step,
  });

  final GameInstructionsStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTheme;
    final currentStep = context.select(
      (GameInstructionsCubit cubit) => cubit.state.currentStep,
    );
    final isActive = step == currentStep;
    return Container(
      width: isActive ? 24 : 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: isActive ? BoxShape.rectangle : BoxShape.circle,
        border: Border.all(color: tokens.border),
        borderRadius: isActive ? BorderRadius.circular(10) : null,
        gradient: LinearGradient(
          colors: isActive
              ? [tokens.primary, tokens.primaryDark]
              : [tokens.muted, tokens.card],
        ),
      ),
    );
  }
}
