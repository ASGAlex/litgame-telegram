import 'package:litgame_telegram/core/core.dart';

import '../events.dart';

class _InGameModeEvent extends LitGameEvent {
  _InGameModeEvent() : super(LitUser.clone());

  @override
  dynamic get type => GenericEvents.inGameMode;
}

mixin SubProcessModeSwitch on GameBaseProcess {
  void switchToInGameMode() {
    add(_InGameModeEvent());
  }
}
