part of 'process.dart';

class GameFlowMasterInitStoryState extends LitGameState {
  GameFlowMasterInitStoryState([this.initFinished]);

  final Future<List<Card>>? initFinished;

  @override
  List get acceptedEvents => [GameEvent.start, GameEvent.nextTurn];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    if (event is GameFlowStartEvent) {
      var finished = bp.game.gameFlowFactory().then((gameFlow) {
        final cGeneric = gameFlow.getCard(CardType.generic);
        final cPlace = gameFlow.getCard(CardType.place);
        final cPerson = gameFlow.getCard(CardType.person);

        return <Card>[cGeneric, cPlace, cPerson];
      });
      return GameFlowMasterInitStoryState(finished);
    }

    if (event is GameFlowNextTurnEvent) {
      bp.game.gameFlow.nextTurn();
      return GameFlowPlayerSelectCardState();
    }
  }
}

class GameFlowPlayerSelectCardState extends LitGameState {
  GameFlowPlayerSelectCardState();

  @override
  List get acceptedEvents => [GameEvent.cardSelected];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    event as GameFlowCardSelectedEvent;
    final type = CardType.generic.getTypeByName(event.cardType);
    final card = bp.game.gameFlow.getCard(type);
    return GameFlowStoryTellState(card);
  }
}

class GameFlowStoryTellState extends LitGameState {
  GameFlowStoryTellState(this.card);

  final Card card;

  @override
  List get acceptedEvents => [GameEvent.nextTurn];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    event as GameFlowNextTurnEvent;
    bp.game.gameFlow.nextTurn();
    return GameFlowPlayerSelectCardState();
  }
}
