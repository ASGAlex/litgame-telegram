import 'dart:math';

import 'package:litgame_telegram/models/cards/card.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';

class GameFlow {
  static final Map<int, GameFlow> _runningGames = {};

  GameFlow(this.game) {
    _user = game.playersSorted.first;
    _collection = CardCollection('default');
    _collection.cards.forEach((key, value) {
      cards[key] = List.from(value);
    });
  }

  final LitGame game;
  late CardCollection _collection;
  Map<String, List<Card>> cards = {};

  late LinkedUser _user;
  int turnNumber = 1;

  factory GameFlow.init(LitGame game) {
    var flow = _runningGames[game.chatId];
    flow ??= GameFlow(game);
    _runningGames[game.chatId] = flow;
    return flow;
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
      var cc = _collection.cards[type.value()];
      if (cc != null) {
        cc.shuffle(Random(cc.length));
        cards[type.value()] = List.from(cc);
        return getCard(type);
      }
    }
    return list.removeLast();
  }
}
