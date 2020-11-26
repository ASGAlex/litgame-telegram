import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class EndGameCmd extends Command {
  @override
  String get name => 'endgame';

  @override
  void run(Message message, Telegram telegram) {
    checkGameChat(message);
    var game = LitGame.find(message.chat.id);
    var userId = message.from.id;
    if (game != null) {
      const errorMessage = 'У тебя нет власти надо мной! Пусть админ игры её остановит.';
      var player = game.players[userId];
      if (player == null) {
        throw errorMessage;
      }
      if (!player.isAdmin) {
        throw errorMessage;
      }
    }
    LitGame.stopGame(message.chat.id);
    telegram.sendMessage(message.chat.id, 'Всё, наигрались!',
        reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
  }

  @override
  ArgParser? getParser() => null;
}
