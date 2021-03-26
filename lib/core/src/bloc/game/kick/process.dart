import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/main/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/setup_game/process.dart';

part 'events.dart';
part 'states.dart';

class KickProcess extends GameBaseProcess {
  KickProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);

  @override
  LitGameState? processEvent(LitGameEvent event) {
    event as KickFromGameEvent;
    if (state is InvitingGameState) {
      var success = game.removePlayer(event.targetUser);
      return InvitingGameState(event.targetUser, success);
    } else {}
    return super.processEvent(event);
  }
}
