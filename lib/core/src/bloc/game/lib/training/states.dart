part of 'process.dart';

class TrainingFlowState extends LitGameState {
  TrainingFlowState([this.initFinished]);

  final Future? initFinished;

  @override
  List get acceptedEvents => [
        TrainingEvent.start,
        TrainingEvent.nextTurn,
      ];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    if (event is TrainingStartEvent) {
      Future finished;
      if (event.collectionId != null) {
        finished = CardCollection.getName(event.collectionId as String)
            .then((collection) {
          return _initTrainingFlow(bp.game, collection.name);
        });
      } else {
        finished = _initTrainingFlow(bp.game, 'default');
      }

      return TrainingFlowState(finished);
    }

    if (event is TrainingNextTurnEvent) {
      final finished = bp.game.trainingFlow.then((trainingFlow) {
        trainingFlow.nextTurn();
      });
      return TrainingFlowState(finished);
    }
  }

  Future _initTrainingFlow(LitGame game, String collectionName) {
    return game.gameFlowFactory(collectionName).then((value) {
      return game.trainingFlow;
    });
  }
}
