import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

import 'joinme.dart';

class KickMeCmd extends JoinMeCmd {
  @override
  String get name => 'kickme';

  @override
  void run(Message message, Telegram telegram) {
    final game = LitGame.find(message.chat.id);
    if (game == null) {
      throw 'В этом чате нет запущенных игр';
    }

    final user = game.players[message.from.id];
    if (user?.isAdmin == true) {
      if (game.players.length <= 1) {
        LitGame.stopGame(message.chat.id);
        telegram.sendMessage(message.chat.id, 'Всё, наигрались!',
            reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
      } else {
        // TODO: show new admin selection dialog
        LitGame.stopGame(message.chat.id);
        telegram.sendMessage(message.chat.id, 'Всё, наигрались!',
            reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
      }
    } else if (user != null) {
      game.removePlayer(user);
      sendStatisticsToAdmin(game, telegram, message.chat.id);
    }
  }

  @override
  ArgParser? getParser() => null;
}
