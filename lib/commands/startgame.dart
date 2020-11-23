import 'package:litgame_telegram/buttons/core.dart';
import 'package:litgame_telegram/buttons/join_game.dart';
import 'package:litgame_telegram/commands/core.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class StartGameCmd extends Command {
  static const String BTN_YES = 'Участвую!';
  static const String BTN_NO = 'Неть...';

  @override
  String get name => 'startgame';

  @override
  void run(Message message, Telegram telegram) {
    checkGameChat(message);
    LitGame.startNew(message.chat.id).addPlayer(LitUser(message.from, isAdmin: true));
    telegram
        .sendMessage(message.chat.id, "Начинаем новую игру! Кто хочет поучаствовать?",
            reply_markup: ReplyKeyboardMarkup(keyboard: [
              [
                KeyboardButton(text: StartGameCmd.BTN_YES, request_contact: false),
                KeyboardButton(text: StartGameCmd.BTN_NO, request_contact: false)
              ]
            ]))
        .then((message) {
      ButtonCallbackController().registerCallback(
          message.chat.id, message.message_id, JoinGame(message.message_id));
    });
  }
}
