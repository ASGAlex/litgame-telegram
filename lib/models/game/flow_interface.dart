import 'package:litgame_telegram/models/game/user.dart';

abstract class FlowInterface {
  void nextTurn();
  LitUser get currentUser;
}
