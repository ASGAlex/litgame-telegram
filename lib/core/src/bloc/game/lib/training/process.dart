import 'package:litgame_telegram/core/core.dart';

part 'events.dart';
part 'states.dart';

class TrainingFlowProcess extends GameBaseProcess {
  TrainingFlowProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);

  @override
  LitGameState<GameBaseProcess>? processEvent(LitGameEvent event) {
    // TODO: implement processEvent
    throw UnimplementedError();
  }
}
