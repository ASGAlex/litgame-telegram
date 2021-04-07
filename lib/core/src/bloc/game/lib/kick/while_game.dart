part of 'process.dart';

class KickWhilePlayingState extends KickWhileInvitingState {
  KickWhilePlayingState(
      [LitUser? lastProcessedUser,
      bool? lastOperationSuccess,
      bool noPlayersLeft = false])
      : super(lastProcessedUser, lastOperationSuccess, noPlayersLeft);

  LitUser? targetUser;

  @override
  List get acceptedEvents => [KickEvent.kick, KickEvent.kickStageFinished];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    // only game master or admin can kick other players!
    if (!event.triggeredBy.isAdmin && !event.triggeredBy.isGameMaster) {
      return null;
    }

    if (targetUser != null) return null;

    if (event is KickFromGameEvent) {
      targetUser = event.targetUser;
      final stateType = bp.parent?.state.runtimeType;
      if (stateType == TrainingState || stateType == GameFlowState) {
        if (event.targetUser.isAdmin) {
          if (bp.game.players.length == 1) {
            bp.parent?.add(GameFinishedEvent(event.triggeredBy));
            return null;
          }

          if (bp.parent?.state.runtimeType != FlowPausedState) {
            bp.parent?.add(FlowPauseEvent(event.triggeredBy));
          }
          final process = bp.runSubProcess(() => SetupGameProcess(
              SelectAdminWhilePlayingState(), bp.game,
              parent: bp, tag: 'setup-admin-kick')) as SetupGameProcess;
          process.runAdminKick(event.triggeredBy, event.targetUser);
        }
      }
      return null;
    }

    if (event is KickStageFinished) {
      bp.stopSubProcess(event.stageProcessTag);
      if (event.stageProcessTag == 'setup-admin-kick') {
        if (targetUser?.isGameMaster == true) {
          final process = bp.runSubProcess(() => SetupGameProcess(
              SelectMasterWhilePlayingState(), bp.game,
              parent: bp, tag: 'setup-master-kick')) as SetupGameProcess;
          process.runMasterKick(event.triggeredBy, targetUser as LitUser);
        } else {
          kick();
          targetUser = null;
          return null;
        }
      } else if (event.stageProcessTag == 'setup-master-kick') {
        kick();
        final lastState = bp.parent?.lastState;
        if (lastState == null) {
          throw 'Invalid game previous state';
        }
        if (lastState is GameFlowMasterInitStoryState) {
          bp.parent?.add(GameFlowStartEvent(targetUser as LitUser));
          return null;
        } else if (lastState is TrainingFlowState) {}
      }
    }
  }

  void kick() {
    bp.game.removePlayer(targetUser as LitUser);
  }
}
