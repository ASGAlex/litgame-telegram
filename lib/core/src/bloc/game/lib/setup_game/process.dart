import 'package:litgame_telegram/core/core.dart';

part 'events.dart';
part 'while_game.dart';
part 'while_setup.dart';

class SetupGameProcess extends GameBaseProcess {
  SetupGameProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}
