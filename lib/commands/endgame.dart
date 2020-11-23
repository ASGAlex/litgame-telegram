import 'package:litgame_telegram/commands/core.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class EndGameCmd extends Command {
  @override
  String get name => 'endgame';

  @override
  void run(Message message, Telegram telegram) {
    checkGameChat(message);
    LitGame.stopGame(message.chat.id);
    telegram.sendMessage(message.chat.id, "Всё, наигрались!",
        reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
  }
}
