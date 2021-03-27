part of 'process.dart';

abstract class LitGameEvent extends Event {
  LitGameEvent(this.triggeredBy, [String? tag]) : super(tag);

  final LitUser triggeredBy;
}

enum MainProcessEvent {
  gameStart,
  setupFinished,
  trainingFinished,
  gameFinished
}

class GameStartEvent extends LitGameEvent {
  GameStartEvent(LitUser triggeredBy, [String? tag]) : super(triggeredBy, tag);

  @override
  dynamic get type => MainProcessEvent.gameStart;
}

class SetupFinishedEvent extends LitGameEvent {
  SetupFinishedEvent(LitUser triggeredBy, [String? tag])
      : super(triggeredBy, tag);

  @override
  dynamic get type => MainProcessEvent.setupFinished;
}

class TrainingFinishedEvent extends LitGameEvent {
  TrainingFinishedEvent(LitUser triggeredBy) : super(triggeredBy);

  TrainingFinishedEvent.empty() : super(LitUser.byId(0));

  @override
  dynamic get type => MainProcessEvent.trainingFinished;
}

class GameFinishedEvent extends LitGameEvent {
  GameFinishedEvent(LitUser triggeredBy) : super(triggeredBy);

  @override
  dynamic get type => MainProcessEvent.gameFinished;
}
