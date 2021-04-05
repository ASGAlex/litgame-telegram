import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/src/flow_pause_resume.dart';

part 'events.dart';
part 'while_game.dart';
part 'while_setup.dart';

class KickProcess extends GameBaseProcess with SubProcessModeSwitch {
  KickProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}
