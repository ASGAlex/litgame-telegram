import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class FinishJoinCmd extends Command {
  @override
  // TODO: implement name
  String get name => 'finishjoin';

  @override
  void run(Message message, Telegram telegram) {
    cleanScheduledMessages(telegram);
    var message = 'Выберите мастера игры: ';
    final keyboard = <List<InlineKeyboardButton>>[];
    game?.players.values.forEach((player) {
      var text = player.nickname + ' (' + player.fullName + ')';
      if (player.isAdmin) {
        text += '(admin)';
      }
      if (player.isGameMaster) {
        text += '(master)';
      }

      keyboard.add([
        InlineKeyboardButton(
            text: text,
            callback_data: '/setmaster --gameChatId=' +
                gameChatId.toString() +
                ' --userId=' +
                player.telegramUser.id.toString())
      ]);
    });

    telegram
        .sendMessage(game?.admin.chatId, message,
            reply_markup: InlineKeyboardMarkup(inline_keyboard: keyboard))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  @override
  ArgParser getParser() => getBaseParser();
}
