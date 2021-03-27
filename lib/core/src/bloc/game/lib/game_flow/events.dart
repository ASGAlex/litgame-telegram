part of 'process.dart';

enum GameEvent { start, nextTurn, cardSelected }

class GameFlowStartEvent extends LitGameEvent {
  GameFlowStartEvent(LitUser triggeredBy, [String? collectionId, String? tag])
      : super(triggeredBy, tag);

  final String? collectionId = null;

  @override
  dynamic get type => GameEvent.start;
}

class GameFlowNextTurnEvent extends LitGameEvent {
  GameFlowNextTurnEvent(LitUser triggeredBy, [String? tag])
      : super(triggeredBy, tag);

  @override
  dynamic get type => GameEvent.nextTurn;
}

class GameFlowCardSelectedEvent extends LitGameEvent {
  GameFlowCardSelectedEvent(LitUser triggeredBy, this.cardType, [String? tag])
      : super(triggeredBy, tag);
  final String cardType;

  @override
  dynamic get type => GameEvent.cardSelected;
}
