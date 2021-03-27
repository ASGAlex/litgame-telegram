import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/src/events.dart';

part 'events.dart';
part 'states.dart';

class InviteProcess extends GameBaseProcess with SubProcessModeSwitch {
  InviteProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}
