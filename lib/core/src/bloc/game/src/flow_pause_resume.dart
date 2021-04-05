import 'package:litgame_telegram/core/core.dart';

enum GenericEvents { inGameMode, flowPause, flowResume }

class FlowPauseEvent extends LitGameEvent {
  FlowPauseEvent(LitUser triggeredBy) : super(triggeredBy);

  @override
  GenericEvents get type => GenericEvents.flowPause;
}

class FlowResumeEvent extends LitGameEvent {
  FlowResumeEvent(LitUser triggeredBy) : super(triggeredBy);

  @override
  GenericEvents get type => GenericEvents.flowResume;
}

class FlowPausedState extends LitGameState {
  @override
  List get acceptedEvents => [GenericEvents.flowResume];

  @override
  LitGameState<GameBaseProcess>? processEvent(LitGameEvent event) {
    return bp.lastState;
  }
}

mixin PausedProcess on GameBaseProcess {
  @override
  List get acceptedEvents => [GenericEvents.flowPause];

  @override
  LitGameState<GameBaseProcess>? processEvent(LitGameEvent event) {
    if (event is FlowPauseEvent) {
      return FlowPausedState();
    }
  }
}

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
