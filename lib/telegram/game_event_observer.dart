import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/core/core.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

import 'commands/commands.dart';

class GameEventObserver extends BlocObserver with MessageDeleter {
  GameEventObserver(this.telegram);

  final TelegramEx telegram;

  @override
  void onError(BlocBase cubit, Object error, StackTrace stackTrace) {
    if (error.runtimeType != BlocError) {
      print(error);
    } else {
      error as BlocError;
      if (error.messageForGroup != null) {
        telegram.sendMessage(
            cubit.state.game.id, error.messageForGroup.toString());
      }
      if (error.messageForUser != null) {
        telegram.sendMessage(
            cubit.state.triggeredBy.chatId, error.messageForUser.toString());
      }
    }
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) async {
    bloc as GameBloc;
    final event = transition.event as GameEvent;
    switch (transition.nextState.runtimeType) {
      case InvitingGameState:
        var state = transition.nextState as InvitingGameState;
        if (transition.currentState is NoGameState) {
          StartGameCmd().afterGameStart(bloc, transition);
        } else if (transition.currentState is InvitingGameState ||
            transition.currentState is SelectAdminState) {
          final cmd = JoinMeCmd();
          if (event is JoinGameEvent) {
            if (state.lastOperationSuccess) {
              cmd.sendChatIdRequest(
                  bloc.game, state.lastProcessedUser, telegram);
              cmd.sendStatisticsToAdmin(bloc.game);
            } else {
              final curGame =
                  LitGame.findGameOfPlayer(event.triggeredBy.chatId);
              if (curGame != bloc.game) {
                cmd.sendPrivateDetailedAlert(state.lastProcessedUser);
                cmd.sendPublicAlert(state.gameId, state.lastProcessedUser);
              }
            }
          } else if (event is RestoreLastStateEvent) {
            cmd.sendStatisticsToAdmin(bloc.game);
          }
        }
        if (event.runtimeType == KickFromGameEvent &&
            state.lastOperationSuccess) {
          final cmd = KickMeCmd();
          cmd.sendStatisticsToAdmin(bloc.game);
          cmd.sendKickMessage(bloc.game, state.lastProcessedUser);
        }
        break;
      case NoGameState:
        EndGameCmd().afterGameEnd(bloc, transition);
        break;
      case SelectGameMasterState:
        SetMasterCmd().showSelectionDialogToAdmin(bloc.game);
        break;

      case PlayerSortingState:
        final state = transition.nextState as PlayerSortingState;
        final cmd = SetOrderCmd();
        if (state.sorted) {
          cmd.showSortFinishedMessage(bloc.game);
        } else {
          cmd.showSelectOrderDialog(bloc.game);
        }
        break;

      case TrainingFlowState:
        final cmd = TrainingFlowCmd();
        if (event.runtimeType == TrainingStartEvent) {
          await cmd.showTrainingDescriptionMessage(bloc.game);
          await cmd.showTrainingEndButtonToAdmin(bloc.game);
        }
        cmd.showNextTurnMessage(bloc.game, telegram);
        break;

      case GameFlowMasterInitStoryState:
        final flow = await bloc.game.gameFlowFactory();
        final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'start', {
          'gci': bloc.game.id.toString(),
          'cid': flow.collectionId
        }) as GameFlowCmd;
        cmd.onGameStart(Message(), telegram);
        break;

      case GameFlowPlayerSelectCardState:
        final cmd =
            ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
          'gci': bloc.game.id.toString(),
        }) as GameFlowCmd;
        cmd.printCardSelectionMessages();
        break;

      case GameFlowStoryTellState:
        final cmd =
            ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
          'gci': bloc.game.id.toString(),
        }) as GameFlowCmd;
        final state = transition.nextState as GameFlowStoryTellState;
        cmd.printStoryTellMode(state.selectedCard);
        break;

      case PlayerKickedDuringGame:
        var state = transition.nextState as PlayerKickedDuringGame;
        final cmd = KickMeCmd();
        cmd.sendKickMessage(bloc.game, state.lastProcessedUser);

        switch (transition.currentState.runtimeType) {
          case GameFlowStoryTellState:
          case GameFlowPlayerSelectCardState:
          case GameFlowMasterInitStoryState:
            bloc.add(GameFlowNextTurnEvent(state.lastProcessedUser));
            break;

          case TrainingFlowState:
            bloc.add(TrainingNextTurnEvent(state.lastProcessedUser));
            break;

          case PlayerSortingState:
            bloc.add(ResetPlayersOrderEvent(state.lastProcessedUser));
            break;
        }
        break;

      case SelectAdminState:
        SelectAdminCmd()
            .showSelectionDialogToAdmin(bloc.game, event.triggeredBy);
        break;
    }

    super.onTransition(bloc, transition);
  }
}
