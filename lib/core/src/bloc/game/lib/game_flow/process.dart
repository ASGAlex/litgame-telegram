import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/src/flow_pause_resume.dart';

part 'events.dart';

class GameFlowProcess extends GameBaseProcess with PausedProcess {
  GameFlowProcess(LitGameState initialState, LitGame game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, game, tag: tag, parent: parent);
}

class GameFlowMasterInitStoryState extends LitGameState {
  GameFlowMasterInitStoryState([this.initFinished]);

  final Future<List<Card>>? initFinished;

  @override
  List get acceptedEvents => [GameEvent.start, GameEvent.nextTurn];

  @override
  LitGameState? processEvent(LitGameEvent event) {
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
  LitGameState? processEvent(LitGameEvent event) {
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
  LitGameState? processEvent(LitGameEvent event) {
    event as GameFlowNextTurnEvent;
    bp.game.gameFlow.nextTurn();
    return GameFlowPlayerSelectCardState();
  }
}
