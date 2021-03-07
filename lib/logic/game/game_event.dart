part of 'game_bloc.dart';

@immutable
abstract class GameEvent<T> {
  GameEvent(this.gameId, this.triggeredBy);

  final int gameId;

  LitGame get game => LitGame.find(gameId);
  final LitUser triggeredBy;

  T run();
}

class StartNewGame extends GameEvent<bool> {
  StartNewGame(int gameId, this.admin) : super(gameId, admin);
  final LitUser admin;

  @override
  bool run() => LitGame.startNew(gameId).addPlayer(admin);
}

class JoinNewGame extends GameEvent<bool> {
  JoinNewGame(int gameId, LitUser triggeredBy) : super(gameId, triggeredBy);

  @override
  bool run() {
    if (game.state is InvitingGameState) {
      return game.addPlayer(triggeredBy);
    }
    return false;
  }
}

class KickFromNewGame extends GameEvent<int> {
  KickFromNewGame(int gameId, LitUser triggeredBy) : super(gameId, triggeredBy);

  static const int NEED_ADMIN = 3;
  static const int END_GAME = 2;
  static const int SUCCESS = 1;
  static const int NO_CHANGE = 0;

  @override
  int run() {
    final user = game.players[triggeredBy.chatId];
    if (user?.isAdmin == true) {
      LitGame.stopGame(gameId);
      if (game.players.length <= 1) {
        return END_GAME;
      } else {
        return NEED_ADMIN;
      }
    } else if (user != null) {
      game.removePlayer(user);
      return SUCCESS;
    }
    return NO_CHANGE;
  }
}

class FinishJoinNewGame extends GameEvent<bool> {
  FinishJoinNewGame(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);

  @override
  bool run() {
    return game.state is InvitingGameState && triggeredBy == game.admin;
  }
}

class SelectGameMaster extends GameEvent<bool> {
  SelectGameMaster(int gameId, LitUser triggeredBy, this.master)
      : super(gameId, triggeredBy);

  final LitUser master;
  @override
  bool run() {
    if (triggeredBy != game.admin) {
      return false;
    }
    master.isGameMaster = true;
    return true;
  }
}

class SetPlayerOrder extends GameEvent<int> {
  SetPlayerOrder(int gameId, LitUser triggeredBy, this.nextPlayer)
      : super(gameId, triggeredBy);

  final LitUser nextPlayer;
  static const SORTED = 1;
  static const NOT_SORTED = 0;

  @override
  int run() {
    game.playersSorted.add(LinkedUser(nextPlayer));
    return game.playersSorted.length == game.players.length
        ? SORTED
        : NOT_SORTED;
  }
}

class ResetPlayerOrder extends GameEvent<void> {
  ResetPlayerOrder(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);

  @override
  void run() {
    game.playersSorted.clear();
    game.playersSorted.add(LinkedUser(game.master));
  }
}
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

class StopGame extends GameEvent<int> {
  StopGame(int gameId, LitUser triggeredBy) : super(gameId, triggeredBy);

  static const int SUCCESS = 1;
  static const int NOT_ADMIN = 0;

  @override
  int run() {
    final game = LitGame.find(gameId);
    final player = game.players[triggeredBy.chatId];
    if (player == null || !player.isAdmin) {
      return NOT_ADMIN;
    }
    LitGame.stopGame(gameId);
    GameFlow.stopGame(gameId);
    TrainingFlow.stopGame(gameId);
    return SUCCESS;
  }
}
