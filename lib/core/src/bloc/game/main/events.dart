part of 'process.dart';

abstract class LitGameEvent extends Event {
  LitGameEvent(this.triggeredBy, [String? tag]) : super(tag);

  final LitUser triggeredBy;
}

class GameStartEvent extends LitGameEvent {
  GameStartEvent(LitUser triggeredBy, [String? tag]) : super(triggeredBy, tag);

  GameStartEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => GameStartEvent.empty().runtimeType;
}

class SetupFinishedEvent extends LitGameEvent {
  SetupFinishedEvent(LitUser triggeredBy, [String? tag])
      : super(triggeredBy, tag);

  SetupFinishedEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => SetupFinishedEvent.empty().runtimeType;
}

class TrainingFinishedEvent extends LitGameEvent {
  TrainingFinishedEvent(LitUser triggeredBy) : super(triggeredBy);

  TrainingFinishedEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => TrainingFinishedEvent.empty().runtimeType;
}

class GameEndEvent extends LitGameEvent {
  GameEndEvent(LitUser triggeredBy) : super(triggeredBy);

  GameEndEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => GameEndEvent.empty().runtimeType;
}
