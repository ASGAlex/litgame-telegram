import 'dart:collection';

import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/main/process.dart';

class LitGame {
  LitGame(this.id) : _playersSorted = LinkedList<LinkedUser>() {
    logic = MainProcess(NoGameState(), this);
  }

  static final Map<int, LitGame> _activeGames = {};
  final int id;
  final Map<int, LitUser> _players = {};
  final LinkedList<LinkedUser> _playersSorted;

  late final MainProcess logic;

  TrainingFlow? _trainingFlow;
  GameFlow? _gameFlow;

  Future<TrainingFlow> get trainingFlow async {
    _trainingFlow ??= TrainingFlow.init(await gameFlowFactory());
    return _trainingFlow as TrainingFlow;
  }

  GameFlow get gameFlow => _gameFlow as GameFlow;

  Future<GameFlow> gameFlowFactory([String collectionName = 'default']) async {
    _gameFlow ??= GameFlow.init(this, collectionName);
    await _gameFlow?.init;
    return _gameFlow as GameFlow;
  }

  Map<int, LitUser> get players => _players;

  LinkedList<LinkedUser> get playersSorted => _playersSorted;

  bool get isEmpty => id == -1;

  LitUser get master {
    for (var u in _players.values) {
      if (u.isGameMaster) return u;
    }
    throw 'АХТУНГ!!! Я потерял гейм-мастера!!!';
  }

  LitUser get admin {
    for (var u in _players.values) {
      if (u.isAdmin) return u;
    }
    return master;
  }

  factory LitGame.startNew(int chatId) {
    if (_activeGames[chatId] != null) {
      throw 'Игра в этом чатике уже запущена, алё!';
    }
    final game = LitGame(chatId);
    _activeGames[chatId] = game;
    return game;
  }

  static LitGame find(int chatId) {
    final game = _activeGames[chatId];
    if (game == null) {
      throw 'Игра не найдена';
    }
    return game;
  }

  static void stopGame(int chatId) {
    if (_activeGames[chatId] == null) {
      throw 'Вообще-то мы даже не начинали...';
    }
    final game = _activeGames.remove(chatId);
    game?.logic.close();
  }

  static LitUser? findPlayerInExistingGames(int chatId) {
    for (var game in _activeGames.entries) {
      final player = game.value.players[chatId];
      if (player != null) {
        return player;
      }
    }
  }

  static LitGame? findGameOfPlayer(int chatId) {
    for (var game in _activeGames.entries) {
      final player = game.value.players[chatId];
      if (player != null) {
        return game.value;
      }
    }
  }

  @override
  bool operator ==(other) {
    if (other is LitGame) {
      return id == other.id;
    }
    return false;
  }

  bool isPlayerPlaying(LitUser user) =>
      findPlayerInExistingGames(user.chatId) != null;

  bool addPlayer(LitUser user) {
    if (isPlayerPlaying(user)) {
      return false;
    }
    user.currentGame = this;
    _players[user.telegramUser.id] = user;
    return true;
  }

  bool removePlayer(LitUser user) {
    user.currentGame = null;
    var success = _players.remove(user.telegramUser.id);
    return success != null;
  }
}
