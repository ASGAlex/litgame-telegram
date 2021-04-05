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
