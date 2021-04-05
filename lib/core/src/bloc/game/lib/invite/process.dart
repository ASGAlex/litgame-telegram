import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/src/flow_pause_resume.dart';

part 'events.dart';

class InviteProcess extends GameBaseProcess with SubProcessModeSwitch {
  InviteProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}

class InviteWhileInvitingGameState extends LitGameState {
  InviteWhileInvitingGameState(
      [this.lastProcessedUser, this.lastOperationSuccess])
      : super();

  final bool? lastOperationSuccess;
  final LitUser? lastProcessedUser;

  @override
  List get acceptedEvents => [JoinEvent.join, GenericEvents.inGameMode];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is JoinGameEvent) {
      final success = bp.game.addPlayer(event.triggeredBy);
      return InviteWhileInvitingGameState(event.triggeredBy, success);
    }

    if (event.type == GenericEvents.inGameMode) {
      return InGameInviteState();
    }
  }
}

class InGameInviteState extends InviteWhileInvitingGameState {
  InGameInviteState([LitUser? lastProcessedUser, bool? lastOperationSuccess])
      : super(lastProcessedUser, lastOperationSuccess);

  @override
  List get acceptedEvents => [JoinEvent.join];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is JoinGameEvent) {
      final success = bp.game.addPlayer(event.triggeredBy);
      return InviteWhileInvitingGameState(event.triggeredBy, success);
    }
  }
}
