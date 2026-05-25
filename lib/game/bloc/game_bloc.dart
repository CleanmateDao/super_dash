import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState.initial()) {
    on<GameXpEarned>(_onGameXpEarned);
    on<GameOver>(_onGameOver);
    on<GameSectionCompleted>(_onGameSectionCompleted);
  }

  void _onGameXpEarned(
    GameXpEarned event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        xp: state.xp + event.amount,
      ),
    );
  }

  void _onGameOver(
    GameOver event,
    Emitter<GameState> emit,
  ) {
    emit(const GameState.initial());
  }

  void _onGameSectionCompleted(
    GameSectionCompleted event,
    Emitter<GameState> emit,
  ) {
    if (state.currentSection < event.sectionCount - 1) {
      emit(
        state.copyWith(
          currentSection: state.currentSection + 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          currentSection: 0,
          currentLevel: state.currentLevel + 1,
        ),
      );
    }
  }
}
