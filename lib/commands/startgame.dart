import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class StartGameCmd extends Command {
  static const String BTN_YES = 'Участвую!';
  static const String BTN_NO = 'Неть...';

  @override
  String get name => 'startgame';

  @override
  bool get system => false;

  @override
  void run(Message message, Telegram telegram) {
    checkGameChat(message);
    LitGame.startNew(message.chat.id).addPlayer(LitUser(message.from, isAdmin: true));
    telegram
        .sendMessage(message.chat.id, 'Начинаем новую игру! Кто хочет поучаствовать?',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: StartGameCmd.BTN_YES, callback_data: '/joinme'),
                InlineKeyboardButton(text: StartGameCmd.BTN_NO, callback_data: '/kickme')
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  @override
  ArgParser? getParser() => null;
}
