import 'package:litgame_telegram/core/core.dart';

part 'events.dart';

class MainProcess extends GameBaseProcess {
  MainProcess(LitGameState initialState, LitGame game, [String? tag])
      : super(initialState, game, tag: tag);

  InviteProcess get bpInvite => findSubProcess('invite') as InviteProcess;

  KickProcess get bpKick => findSubProcess('kick') as KickProcess;

  TrainingFlowProcess get bpTraining =>
      findSubProcess('training') as TrainingFlowProcess;

  @override
  List get acceptedEvents => [MainProcessEvent.gameFinished];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is GameFinishedEvent) {
      final player = game.players[event.triggeredBy.chatId];
      if ((player != null && player.isAdmin) || (game.players.isEmpty)) {
        LitGame.stopGame(game.id);
        GameFlow.stopGame(game.id);
        TrainingFlow.stopGame(game.id);
        return NoGameState();
      } else {
        addError(BlocError(event,
            messageForGroup:
                'У тебя нет власти надо мной! Пусть админ игры её остановит.'));
      }
    }
  }
}

abstract class _MainProcessState extends LitGameState<MainProcess> {}

class NoGameState extends _MainProcessState {
  @override
  List get acceptedEvents => [MainProcessEvent.gameStart];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    event as GameStartEvent;
    event.triggeredBy.isAdmin = true;
    bp.game.addPlayer(event.triggeredBy);
    try {
      final setup = bp.runSubProcess(() => SetupGameProcess(
          InvitingGameState(), bp.game,
          tag: 'setup', parent: bp));
      final invite = bp.runSubProcess(() => InviteProcess(
          InviteWhileInvitingGameState(), bp.game,
          tag: 'invite', parent: bp));
      final kick = bp.runSubProcess(() => KickProcess(
          KickWhileInvitingState(), bp.game,
          tag: 'kick', parent: bp));
    } catch (error) {
      addError(BlocError(event,
          messageForUser: 'Game configuration process already running'));
    }
    return SetupGameState();
  }
}

class SetupGameState extends _MainProcessState {
  @override
  List get acceptedEvents => [MainProcessEvent.setupFinished];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event.triggeredBy.isAdmin || event.triggeredBy.isGameMaster) {
      bp.stopSubProcess('setup');
      final training = bp.runSubProcess(() => TrainingFlowProcess(
          TrainingFlowState(), bp.game,
          tag: 'training', parent: bp));
      bp.bpKick.switchToInGameMode();
      bp.bpInvite.switchToInGameMode();
      return TrainingState();
    } else {
      addError(BlocError(event,
          messageForGroup:
              event.triggeredBy.nickname + ' у тебя нет власти надо мной!'));
    }
  }
}

class TrainingState extends _MainProcessState {
  @override
  List get acceptedEvents => [MainProcessEvent.trainingFinished];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event.triggeredBy.isAdmin || event.triggeredBy.isGameMaster) {
      bp.stopSubProcess('training');
      bp.runSubProcess(() => GameFlowProcess(
          GameFlowMasterInitStoryState(), bp.game,
          tag: 'game', parent: bp));
      return GameFlowState();
    } else {
      addError(BlocError(event,
          messageForGroup:
              event.triggeredBy.nickname + ' у тебя нет власти надо мной!'));
    }
  }
}

class GameFlowState extends _MainProcessState {
  @override
  List get acceptedEvents => [];

  @override
  LitGameState? processEvent(Event event) {
    throw UnimplementedError();
  }
}
