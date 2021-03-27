part of 'process.dart';

abstract class _MainProcessState extends LitGameState<MainProcess> {}

class NoGameState extends _MainProcessState {
  @override
  List get acceptedEvents => [MainProcessEvent.gameStart];

  @override
  LitGameState? onEvent(LitGameEvent event, MainProcess bp) {
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
  LitGameState? onEvent(LitGameEvent event, MainProcess bp) {
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
  LitGameState? onEvent(LitGameEvent event, MainProcess bp) {
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
  LitGameState? onEvent(Event event, MainProcess bp) {
    throw UnimplementedError();
  }
}
