import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/main/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/setup_game/process.dart';

part 'events.dart';

class InviteProcess extends GameBaseProcess {
  InviteProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);

  @override
  LitGameState? processEvent(LitGameEvent event) {
    event as JoinGameEvent;
    if (state is InvitingGameState) {
      final success = game.addPlayer(event.triggeredBy);
      return InvitingGameState(event.triggeredBy, success);
    } else {
      return super.processEvent(event);
    }
  }
}
