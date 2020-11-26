import 'package:litgame_telegram/models/game/game.dart';

class GameFlow {
  GameFlow(this.game) {
    playerCursor = game.players.values.iterator;
  }
  final LitGame game;
  late Iterator playerCursor;

  // Card getCard(CardType type) {}
}
