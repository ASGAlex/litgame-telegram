import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/main/process.dart';
import 'package:litgame_telegram/core/src/models/game/user.dart';

part 'events.dart';
part 'states.dart';

class KickProcess extends GameBaseProcess {
  KickProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}
