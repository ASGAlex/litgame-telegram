part of 'process.dart';

class TrainingStartEvent extends LitGameEvent {
  TrainingStartEvent(LitUser triggeredBy, [String? collectionId, String? tag])
      : super(triggeredBy, tag);

  TrainingStartEvent.empty() : super(LitUser.byId(0));

  final String? collectionId = null;

  @override
  Type get type => TrainingStartEvent.empty().runtimeType;
}

class TrainingNextTurnEvent extends LitGameEvent {
  TrainingNextTurnEvent(LitUser triggeredBy, [String? tag])
      : super(triggeredBy, tag);

  TrainingNextTurnEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => TrainingNextTurnEvent.empty().runtimeType;
}
