import 'package:litgame_telegram/core/core.dart';

abstract class GameBaseProcess
    extends BusinessProcess<LitGameEvent, LitGameState> {
  GameBaseProcess(LitGameState initialState, this.game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, tag: tag, parent: parent);
  final LitGame game;
}
