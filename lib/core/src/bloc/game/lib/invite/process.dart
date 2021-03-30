import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/src/events.dart';
import 'package:litgame_telegram/core/src/bloc/game/src/mixin/sub_process_mode_switch.dart';

part 'events.dart';
part 'states.dart';

class InviteProcess extends GameBaseProcess with SubProcessModeSwitch {
  InviteProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);

  @override
  LitGameState<GameBaseProcess>? processEvent(LitGameEvent event) {
    // TODO: implement processEvent
    throw UnimplementedError();
  }
}
