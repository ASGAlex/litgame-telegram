part of 'process.dart';

class InviteWhileInvitingGameState extends LitGameState {
  InviteWhileInvitingGameState(
      [this.lastProcessedUser, this.lastOperationSuccess])
      : super();

  final bool? lastOperationSuccess;
  final LitUser? lastProcessedUser;

  @override
  List get acceptedEvents => [JoinEvent.join];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    if (event is JoinGameEvent) {
      final success = bp.game.addPlayer(event.triggeredBy);
      return InviteWhileInvitingGameState(event.triggeredBy, success);
    }
  }
}
