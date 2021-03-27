part of 'process.dart';

enum TrainingEvent { start, nextTurn }

class TrainingStartEvent extends LitGameEvent {
  TrainingStartEvent(LitUser triggeredBy, [String? collectionId, String? tag])
      : super(triggeredBy, tag);

  final String? collectionId = null;

  @override
  dynamic get type => TrainingEvent.start;
}

class TrainingNextTurnEvent extends LitGameEvent {
  TrainingNextTurnEvent(LitUser triggeredBy, [String? tag])
      : super(triggeredBy, tag);

  @override
  dynamic get type => TrainingEvent.nextTurn;
}
