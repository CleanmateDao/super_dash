import 'dart:async';
import 'dart:ui';

import 'package:cleanmate_rush/game/cleanmate_rush_game.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';

class TreeSign extends TextComponent with HasGameRef<CleanmateRushGame> {
  TreeSign({
    super.position,
  }) : super(
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Color(0xffffffff),
              fontSize: 24,
            ),
          ),
        );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final currentLevel = gameRef.state.currentLevel;
    text = 'DAY $currentLevel';
  }
}
