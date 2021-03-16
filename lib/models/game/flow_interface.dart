import 'package:litgame_telegram/models/game/user.dart';

import 'game.dart';

abstract class FlowInterface {
  void nextTurn();
  LitUser get currentUser;
  LitGame get game;
}
