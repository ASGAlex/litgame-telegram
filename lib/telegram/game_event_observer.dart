import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/core/core.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

import 'commands/commands.dart';

class GameEventObserver extends BlocObserver with MessageDeleter {
  GameEventObserver(this.telegram);

  final TelegramEx telegram;

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
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
        if (transition.currentState.runtimeType == NoGameState) {
          StartGameCmd().afterGameStart(bloc, transition);
        } else if (transition.currentState.runtimeType == InvitingGameState) {
          if (event.runtimeType == JoinGameEvent) {
            final cmd = JoinMeCmd();
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

      case GameFlowMasterInitStory:
        final flow = await bloc.game.gameFlowFactory();
        final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'start', {
          'gci': bloc.game.id.toString(),
          'cid': flow.collectionId
        }) as GameFlowCmd;
        cmd.onGameStart(Message(), telegram);
        break;

      case GameFlowPlayerSelectCard:
        final cmd =
            ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
          'gci': bloc.game.id.toString(),
        }) as GameFlowCmd;
        cmd.printCardSelectionMessages();
        break;

      case GameFlowStoryTell:
        final cmd =
            ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
          'gci': bloc.game.id.toString(),
        }) as GameFlowCmd;
        final state = transition.nextState as GameFlowStoryTell;
        cmd.printStoryTellMode(state.selectedCard);
        break;

      case PlayerKickedDuringGame:
        var state = transition.nextState as PlayerKickedDuringGame;
        final cmd = KickMeCmd();
        cmd.sendKickMessage(bloc.game, state.lastProcessedUser);

        switch (transition.currentState.runtimeType) {
          case GameFlowStoryTell:
          case GameFlowPlayerSelectCard:
          case GameFlowMasterInitStory:
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
    }

    super.onTransition(bloc, transition);
  }
}
