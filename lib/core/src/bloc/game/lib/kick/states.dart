part of 'process.dart';

class KickWhileInvitingState extends LitGameState {
  KickWhileInvitingState(
      [this.lastProcessedUser,
      this.lastOperationSuccess,
      this.noPlayersLeft = false])
      : super();

  final bool? lastOperationSuccess;
  final LitUser? lastProcessedUser;
  final bool noPlayersLeft;

  @override
  List get acceptedEvents => [KickEvent.kick, GenericEvents.inGameMode];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is KickFromGameEvent) {
      var success = bp.game.removePlayer(event.targetUser);
      if (bp.game.players.isEmpty) {
        bp.parent?.add(GameFinishedEvent(event.triggeredBy));
      }
      return KickWhileInvitingState(
          event.targetUser, success, bp.game.players.isEmpty);
    }
    if (event.type == GenericEvents.inGameMode) {
      return KickWhilePlayingState();
    }
  }
}

class KickWhilePlayingState extends KickWhileInvitingState {
  KickWhilePlayingState(
      [LitUser? lastProcessedUser,
      bool? lastOperationSuccess,
      bool noPlayersLeft = false])
      : super(lastProcessedUser, lastOperationSuccess, noPlayersLeft);

  @override
  List get acceptedEvents => [KickEvent.kick];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is KickFromGameEvent) {
      final stateType = bp.parent?.state.runtimeType;
      if (stateType == TrainingState || stateType == GameFlowState) {
        // only game master or admin can kick other players!
        if (event.targetUser != event.triggeredBy &&
            !event.triggeredBy.isAdmin &&
            !event.triggeredBy.isGameMaster) return null;

        if (event.targetUser.isAdmin) {
          // bp.parent.add(event);
        }
      }
    }
  }
}
