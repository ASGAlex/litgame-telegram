import 'package:litgame_telegram/core/core.dart';

part 'events.dart';
part 'states.dart';

class GameFlowProcess extends GameBaseProcess {
  GameFlowProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}
