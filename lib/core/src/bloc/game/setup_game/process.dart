import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/main/process.dart';

import '../invite/process.dart';

part 'events.dart';
part 'states.dart';

class SetupGameProcess extends GameBaseProcess {
  SetupGameProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}
