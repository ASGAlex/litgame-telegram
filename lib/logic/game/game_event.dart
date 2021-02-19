part of 'game_bloc.dart';

@immutable
abstract class GameEvent<T> {
  GameEvent(this.gameId);
  final int gameId;
  T run();
}

class StartNewGame extends GameEvent<bool> {
  StartNewGame(int gameId, this.admin) : super(gameId);
  final LitUser admin;

  @override
  bool run() => LitGame.startNew(gameId).addPlayer(admin);
}
//
// class JoinNewGame extends GameEvent {
//   JoinNewGame(int gameId) : super(gameId);
// }
//
// class FinishJoinNewGame extends GameEvent {
//   FinishJoinNewGame(int gameId) : super(gameId);
// }
//
// class SelectGameMaster extends GameEvent {
//   SelectGameMaster(int gameId) : super(gameId);
// }
//
// class SetPlayerOrder extends GameEvent {
//   SetPlayerOrder(int gameId) : super(gameId);
// }
//
// class ResetPlayerOrder extends GameEvent {
//   ResetPlayerOrder(int gameId) : super(gameId);
// }
//
// class RunTraining extends GameEvent {
//   RunTraining(int gameId) : super(gameId);
// }
//
// class CardCollectionSelected extends GameEvent {
//   CardCollectionSelected(int gameId) : super(gameId);
// }
//
// class RunGame extends GameEvent {
//   RunGame(int gameId) : super(gameId);
// }

class StopGame extends GameEvent<bool> {
  StopGame(int gameId, this.triggeredBy) : super(gameId);
  final LitUser triggeredBy;

  @override
  bool run() {
    final game = LitGame.find(gameId);
    if (game == null) {
      throw GameNotFoundException('Game $gameId not found');
    }
    final player = game.players[triggeredBy.chatId];
    if (player == null || !player.isAdmin) {
      return false;
    }
    LitGame.stopGame(gameId);
    GameFlow.stopGame(gameId);
    TrainingFlow.stopGame(gameId);
    return true;
  }
}
