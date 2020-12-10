import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

class HelpCmd extends ComplexCommand {
  @override
  bool get system => false;

  @override
  Map<String, CmdAction> get actionMap =>
      {'firstRun': onFirstRun, 'aboutGame': onAboutGame};

  @override
  String get name => 'help';

  void onFirstRun(Message message, LitTelegram telegram) {
    telegram.sendMessage(message.chat.id, 'Я запомнил тебя! Обещаю не спамить :-)');
    _sendHelpInitialMessage();
  }

  void onAboutGame(Message message, LitTelegram telegram) {}

  @override
  void onNoAction(Message message, LitTelegram telegram) {
    _sendHelpInitialMessage();
  }

  void _sendHelpInitialMessage() {
    telegram.sendMessage(
        message.chat.id, 'Возникли вопросы? Вот что я могу о себе рассказать: ',
        reply_markup: InlineKeyboardMarkup(inline_keyboard: [
          [
            InlineKeyboardButton(
                text: 'Что такое литигра?', callback_data: buildAction('aboutGame'))
          ],
          [
            InlineKeyboardButton(
                text: 'Я игромастер. Как мне создать и вести игру?',
                callback_data: buildAction('forMaster'))
          ],
          [
            InlineKeyboardButton(
                text: 'Я простой игрок. Как мне играть?',
                callback_data: buildAction('forPlayer'))
          ],
        ]));
  }
}
