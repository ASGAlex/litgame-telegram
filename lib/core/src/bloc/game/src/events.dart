import 'package:litgame_telegram/core/core.dart';

part 'mixin/sub_process_mode_switch.dart';

enum GenericEvents { inGameMode }

class _InGameModeEvent extends LitGameEvent {
  _InGameModeEvent() : super(LitUser.clone());

  @override
  dynamic get type => GenericEvents.inGameMode;
}
