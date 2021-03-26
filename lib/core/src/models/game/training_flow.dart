import 'dart:math';

import 'package:litgame_telegram/core/core.dart';

class TrainingFlow implements FlowInterface {
  static final Map<int, TrainingFlow> _runningTrainings = {};

  TrainingFlow(this.gameFlow) {
    gameFlow.init.then((value) {
      _user = gameFlow.game.playersSorted.first;
      _prepareCards();
    });
  }

  final GameFlow gameFlow;
  late LinkedUser _user;
  int turnNumber = 1;
  late List<Card> cards;

  @override
  LitUser get currentUser => _user.user;

  factory TrainingFlow.init(GameFlow flow) {
    var trainingFlow = _runningTrainings[flow.game.id];
    trainingFlow ??= TrainingFlow(flow);
    _runningTrainings[flow.game.id] = trainingFlow;
    return trainingFlow;
  }

  void _prepareCards() {
    cards = [];
    gameFlow.cards.forEach((key, value) {
      cards.addAll(List.from(value));
    });
    cards.shuffle(Random(cards.length));
  }

  static void stopGame(int chatId) {
    if (_runningTrainings[chatId] != null) {
      _runningTrainings.remove(chatId);
    }
  }

  @override
  void nextTurn() {
    var next = _user.next;
    next ??= gameFlow.game.playersSorted.first;
    _user = next;
    turnNumber++;
  }

  Card getCard() {
    if (cards.isEmpty) {
      _prepareCards();
    }
    return cards.removeLast();
  }

  @override
  LitGame get game => gameFlow.game;
}
