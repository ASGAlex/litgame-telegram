import 'package:litgame_telegram/core/core.dart';

class GameBaseProcess extends BusinessProcess<LitGameEvent, LitGameState> {
  GameBaseProcess(this._stateAfterInit, this.game,
      {String? tag, GameBaseProcess? parent})
      : super(ProcessInitState(), tag: tag, parent: parent) {
    _stateAfterInit.init(this);
    add(ProcessInitEvent(tag));
  }

  final LitGame game;

  final LitGameState _stateAfterInit;

  @override
  Stream<LitGameState<GameBaseProcess>> mapEventToState(
      LitGameEvent event) async* {
    if (event is ProcessInitEvent) {
      yield _stateAfterInit;
    } else {
      yield* super.mapEventToState(event);
    }
  }

  @override
  LitGameState<GameBaseProcess>? processEvent(LitGameEvent event) {
    throw UnimplementedError();
  }
}
