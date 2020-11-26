import 'dart:collection';

import 'package:litgame_telegram/models/game/user.dart';

class LitGame {
  LitGame(this.chatId) : _playersSorted = LinkedList<LinkedUser>();

  static final Map<int, LitGame> _activeGames = {};
  final int chatId;
  final Map<int, LitUser> _players = {};
  final LinkedList<LinkedUser> _playersSorted;

  Map<int, LitUser> get players => _players;

  LinkedList<LinkedUser> get playersSorted => _playersSorted;

  bool get isEmpty => chatId == -1;

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

  static LitGame? find(int chatId) {
    return _activeGames[chatId];
  }

  static void stopGame(int chatId) {
    if (_activeGames[chatId] == null) {
      throw 'Вообще-то мы даже не начинали...';
    }
    _activeGames.remove(chatId);
  }

  bool hasPlayer(LitUser user) {
    return _players.containsKey(user.telegramUser.id);
  }

  bool addPlayer(LitUser user) {
    if (hasPlayer(user)) {
      return false;
    }
    _players[user.telegramUser.id] = user;
    return true;
  }

  void removePlayer(LitUser user) {
    _players.remove(user.telegramUser.id);
  }
}
