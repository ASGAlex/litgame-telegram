// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import '../telegram.dart';

class StartGameCmd extends Command {
  static const String BTN_YES = 'Участвую!';
  static const String BTN_NO = 'Неть...';

  StartGameCmd();

  @override
  String get name => 'startgame';

  @override
  bool get system => false;

  @override
  void run(Message message, LitTelegram telegram) {
    checkGameChat(message);
    LitGame.startNew(message.chat.id).addPlayer(LitUser(message.from, isAdmin: true));
    telegram
        .sendMessage(
            message.chat.id,
            '=========================================\r\n'
            'Начинаем новую игру! \r\n'
            'ВНИМАНИЕ, с кем ещё не общались - напишите мне в личку, чтобы я тоже мог вам отправлять сообщения.\r\n'
            'У вас на планете дискриминация роботов, поэтому сам я вам просто так написать не смогу :-( \r\n'
            '\r\n'
            'Кто хочет поучаствовать?',
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
