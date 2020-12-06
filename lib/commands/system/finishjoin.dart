import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/commands/system/setmaster.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import '../../telegram.dart';

class FinishJoinCmd extends Command {
  FinishJoinCmd();

  FinishJoinCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  String get name => 'finishjoin';

  @override
  void run(Message message, LitTelegram telegram) {
    if (message.chat.id != game.admin.chatId) {
      telegram.sendMessage(message.chat.id, 'Не ты админ текущей игры!');
      return;
    }

    cleanScheduledMessages(telegram);
    final keyboard = <List<InlineKeyboardButton>>[];
    game.players.values.forEach((player) {
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
            callback_data: SetMasterCmd.args(arguments).buildCommandCall({
              'gci': gameChatId.toString(),
              'userId': player.telegramUser.id.toString()
            }))
      ]);
    });

    telegram
        .sendMessage(game.admin.chatId, 'Выберите мастера игры: ',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: keyboard))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  @override
  ArgParser getParser() => getGameBaseParser();
}
