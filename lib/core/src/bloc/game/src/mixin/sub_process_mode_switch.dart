part of '../events.dart';

mixin SubProcessModeSwitch on GameBaseProcess {
  void switchToInGameMode() {
    add(_InGameModeEvent());
  }
}
