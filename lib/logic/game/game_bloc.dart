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
          yield InvitingGameState(event.gameId, event.triggeredBy);
        } else {
          LitGame.stopGame(event.gameId);
          yield NoGame(event.triggeredBy);
        }
        break;
      case StopGame:
        if (eventResult == StopGame.SUCCESS) {
          yield NoGame(event.triggeredBy);
        } else if (eventResult == StopGame.NOT_ADMIN) {
          yield GameState.WithError(state,
              messageForGroup:
                  'У тебя нет власти надо мной! Пусть админ игры её остановит.');
        }
        break;
      case JoinNewGame:
        event as JoinNewGame;
        yield InvitingGameState(
            event.gameId, event.triggeredBy, eventResult, event.triggeredBy);
        break;
      case KickFromNewGame:
        if (eventResult == KickFromNewGame.END_GAME ||
            eventResult == KickFromNewGame.NEED_ADMIN) {
          yield NoGame(event.triggeredBy);
        } else {
          yield InvitingGameState(event.gameId, event.triggeredBy);
        }
        break;
      case FinishJoinNewGame:
        if (eventResult) {
          yield SelectGameMasterState(event.gameId, event.triggeredBy);
        } else {
          yield GameState.WithError(state,
              messageForGroup:
                  'Пресечена незаконная попытка остановить набор игроков!');
        }
        break;
      case SelectGameMaster:
        if (eventResult) {
          yield SetPlayersOrderState(event.gameId, event.triggeredBy);
        } else {
          yield GameState.WithError(state,
              messageForGroup:
                  'Данная операция доступна только администратору!');
        }
    }
  }

  @override
  void onChange(Change<GameState> change) {
    try {
      change.nextState.game?.state = change.nextState;
    } catch (_) {}
    super.onChange(change);
  }
}
