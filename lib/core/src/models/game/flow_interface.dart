import 'package:litgame_telegram/core/core.dart';

abstract class FlowInterface {
  void nextTurn();
  LitUser get currentUser;
  LitGame get game;
}
