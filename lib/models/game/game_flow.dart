import 'dart:math';

import 'package:litgame_telegram/models/cards/card.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';

class GameFlow {
  static final Map<int, GameFlow> _runningGames = {};
  static final Map<String, CardCollection> _loadedCollections = {};

  GameFlow(this.game, [this.collectionName = 'default']) {
    _user = game.playersSorted.first;
    init = CardCollection.fromServer(collectionName).then((loadedCollection) {
      _loadedCollections[collectionName] = loadedCollection;
      _collection?.cards.forEach((key, value) {
        cards[key] = List.from(value);
      });
    });
  }

  final LitGame game;
  final String collectionName;
  late final Future init;
  Map<String, List<Card>> cards = {};

  CardCollection? get _collection => _loadedCollections[collectionName];

  late LinkedUser _user;
  int turnNumber = 1;

  factory GameFlow.init(LitGame game, [String collectionName = '']) {
    var flow = _runningGames[game.chatId];
    flow ??= GameFlow(game, collectionName);
    _runningGames[game.chatId] = flow;
    return flow;
  }

  static void stopGame(int chatId) {
    if (_runningGames[chatId] != null) {
      _runningGames.remove(chatId);
    }
  }

  LitUser get currentUser => _user.user;

  void nextTurn() {
    var next = _user.next;
    next ??= game.playersSorted.first;
    _user = next;
    turnNumber++;
  }

  Card getCard(CardType type) {
    var list = cards[type.value()];
    if (list == null) throw 'Collection error';
    if (list.isEmpty) {
      var cc = _collection?.cards[type.value()];
      if (cc != null) {
        cc.shuffle(Random(cc.length));
        cards[type.value()] = List.from(cc);
        return getCard(type);
      }
    }
    return list.removeLast();
  }
}
