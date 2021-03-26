part of 'process.dart';

class GameFlowStartEvent extends LitGameEvent {
  GameFlowStartEvent(LitUser triggeredBy, [String? collectionId, String? tag])
      : super(triggeredBy, tag);

  GameFlowStartEvent.empty() : super(LitUser.byId(0));

  final String? collectionId = null;

  @override
  Type get type => GameFlowStartEvent.empty().runtimeType;
}

class GameFlowNextTurnEvent extends LitGameEvent {
  GameFlowNextTurnEvent(LitUser triggeredBy, [String? tag])
      : super(triggeredBy, tag);

  GameFlowNextTurnEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => GameFlowNextTurnEvent.empty().runtimeType;
}

class GameFlowCardSelectedEvent extends LitGameEvent {
  GameFlowCardSelectedEvent(LitUser triggeredBy, this.cardType, [String? tag])
      : super(triggeredBy, tag);

  GameFlowCardSelectedEvent.empty()
      : cardType = '',
        super(LitUser.byId(0));
  final String cardType;

  @override
  Type get type => GameFlowCardSelectedEvent.empty().runtimeType;
}
