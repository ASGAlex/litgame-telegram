import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/game_flow.dart';
import 'package:litgame_telegram/models/game/traning_flow.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:meta/meta.dart';

part 'exceptions.dart';
part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(GameState initialState) : super(initialState);

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    var eventResult;
    try {
      eventResult = event.run();
    } catch (exception) {
      if (exception is GameBaseException) {
        print(exception);
        return;
      } else {
        rethrow;
      }
    }
    switch (event.runtimeType) {
      case StartNewGame:
        if (eventResult) {
          yield InvitingGameState(event.gameId);
        } else {
          LitGame.stopGame(event.gameId);
          yield NoGame();
        }
        break;
      case StopGame:
        if (eventResult) yield NoGame();
        break;
      case JoinNewGame:
        event as JoinNewGame;
        yield InvitingGameState(event.gameId, eventResult, event.triggeredBy);
        break;
      case KickFromNewGame:
        if (eventResult == KickFromNewGame.END_GAME ||
            eventResult == KickFromNewGame.NEED_ADMIN) {
          yield NoGame();
        } else {
          yield InvitingGameState(event.gameId);
        }
        break;
    }
  }
}
