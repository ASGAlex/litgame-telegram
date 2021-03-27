import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/core/core.dart';
import 'package:teledart_app/teledart_app.dart';

import 'commands/commands.dart';

class GameEventObserver extends BlocObserver with MessageDeleter {
  GameEventObserver(this.telegram);

  final TelegramEx telegram;

  @override
  void onError(BlocBase cubit, Object error, StackTrace stackTrace) {
    if (cubit is GameBaseProcess) {
      if (error.runtimeType != BlocError) {
        print(error);
      } else {
        error as BlocError;
        if (error.messageForGroup != null) {
          telegram.sendMessage(cubit.game.id, error.messageForGroup.toString());
        }
        if (error.messageForUser != null) {
          telegram.sendMessage(
              error.event.triggeredBy.chatId, error.messageForUser.toString());
        }
      }
    }
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onTransition(Bloc bp, Transition transition) {
    bp as GameBaseProcess;
    if (bp is MainProcess) {
      _mainProcessEvents(bp, transition);
    }

    if (bp is SetupGameProcess) {
      _setupGameProcessEvents(bp, transition);
    }

    if (bp is InviteProcess) {
      _inviteProcessEvents(bp, transition);
    }

    if (bp is KickProcess) {
      _kickProcessEvents(bp, transition);
    }

    if (bp is TrainingFlowProcess) {
      _trainingProcessEvents(bp, transition);
    }

    if (bp is GameFlowProcess) {
      _gameProcessEvents(bp, transition);
    }

    super.onTransition(bp, transition);
  }

  void _mainProcessEvents(MainProcess bp, Transition transition) {
    final tEvent = transition.event as LitGameEvent;
    if (transition.nextState is SetupGameState) {
      StartGameCmd().afterGameStart(bp.game, transition);
    }

    if (transition.nextState is NoGameState) {
      EndGameCmd().afterGameEnd(bp.game, transition);
    }

    if (transition.nextState is TrainingState) {
      final cmd = TrainingFlowCmd();
      cmd.showTrainingDescriptionMessage(bp.game).then((value) {
        cmd.showTrainingEndButtonToAdmin(bp.game);
      });
    }

    if (transition.nextState is GameFlowState) {
      GameFlowCmd().printGameStartMessage(bp.game);
      bp.add(GameFlowStartEvent(tEvent.triggeredBy));
    }
  }

  void _inviteProcessEvents(InviteProcess bp, Transition transition) {
    final tState = transition.nextState;
    final tEvent = transition.event;
    if (tState is InviteWhileInvitingGameState && tEvent is JoinGameEvent) {
      final cmd = JoinMeCmd();
      if (tState.lastOperationSuccess == true) {
        cmd.sendChatIdRequest(
            bp.game, tState.lastProcessedUser as LitUser, telegram);
        cmd.sendStatisticsToAdmin(bp.game);
      } else {
        final curGame = LitGame.findGameOfPlayer(tEvent.userToBeInvited.chatId);
        if (curGame != bp.game) {
          cmd.sendPrivateDetailedAlert(tState.lastProcessedUser as LitUser);
          cmd.sendPublicAlert(bp.game.id, tState.lastProcessedUser as LitUser);
        }
      }
    }
  }

  void _kickProcessEvents(KickProcess bp, Transition transition) {
    final tState = transition.nextState;
    final tEvent = transition.event;

    if (tState is KickWhileInvitingState && tEvent is KickFromGameEvent) {
      final user = tState.lastProcessedUser;
      if (tState.lastOperationSuccess == true &&
          user != null &&
          !tState.noPlayersLeft) {
        final cmd = KickMeCmd();
        cmd.sendStatisticsToAdmin(bp.game);
        cmd.sendKickMessage(bp.game, user);
      }
    }
  }

  void _setupGameProcessEvents(SetupGameProcess bp, Transition transition) {
    final tState = transition.nextState;
    final tEvent = transition.event;
    if (tState is SelectGameMasterState) {
      SetMasterCmd().showSelectionDialogToAdmin(bp.game);
    }

    if (tState is PlayerSortingState) {
      final cmd = SetOrderCmd();
      if (tState.isAllSorted) {
        cmd.showSortFinishedMessage(bp.game);
      } else {
        cmd.showSelectOrderDialog(bp.game);
      }
    }
  }

  void _trainingProcessEvents(TrainingFlowProcess bp, Transition transition) {
    final tState = transition.nextState;
    final tEvent = transition.event;

    final cmd = TrainingFlowCmd();
    if (tState is TrainingFlowState) {
      tState.initFinished?.then((value) {
        cmd.showNextTurnMessage(bp.game, telegram);
      });
    }
  }

  void _gameProcessEvents(GameFlowProcess bp, Transition transition) {
    final tState = transition.nextState;
    final tEvent = transition.event;

    if (tState is GameFlowMasterInitStoryState) {
      tState.initFinished?.then((cards) {
        bp.game.gameFlowFactory().then((flow) {
          final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'start', {
            'gci': bp.game.id.toString(),
            'cid': flow.collectionId
          }) as GameFlowCmd;
          cmd.printCardsForMasterFirstTurn(cards, telegram);
        });
      });
    }

    if (tState is GameFlowPlayerSelectCardState) {
      final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
        'gci': bp.game.id.toString(),
      }) as GameFlowCmd;
      cmd.printCardSelectionMessages();
    }

    if (tState is GameFlowStoryTellState) {
      final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
        'gci': bp.game.id.toString(),
      }) as GameFlowCmd;
      cmd.printStoryTellMode(tState.card);
    }
  }

  @override
  void _onTransition(Bloc bloc, Transition transition) async {
    final event = transition.event as LitGameEvent;
    bloc as GameBaseProcess;
    switch (transition.nextState.runtimeType) {
      case GameFlowPlayerSelectCardState:
        break;

      case GameFlowStoryTellState:
        break;
/*
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
    */
    }

    super.onTransition(bloc, transition);
  }
}
