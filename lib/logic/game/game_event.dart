part of 'game_bloc.dart';

enum GameEventType {
  startNewGame,
  stopGame,
  joinGame,
  kickFromGame,
  finishJoin,
  selectMaster,
  sortPlayer,
  resetPlayersOrder,
  trainingStart,
  trainingNextTurn,
  trainingEnd,
  gameFlowStart,
  gameFlowNextTurn,
  gameFlowCardSelected,
}

@immutable
class GameEvent {
  GameEvent(this.type, this.triggeredBy, [this.additionalData]);

  final GameEventType type;
  final LitUser triggeredBy;
  final dynamic additionalData;
}
