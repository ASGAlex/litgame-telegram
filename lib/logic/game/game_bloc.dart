import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:meta/meta.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(GameState initialState) : super(initialState);

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    final eventResult = event.run();
    switch (event.runtimeType) {
      case StartNewGame:
        if (eventResult) {
          yield InvitingGameState();
        } else {
          add(StopGame(event.gameId));
        }
        break;
      case StopGame:
        yield NoGame();
        break;
    }
  }
}
