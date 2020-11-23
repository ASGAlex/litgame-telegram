import 'package:litgame_telegram/commands/core.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

import 'buttons/core.dart';

class Router {
  Router(Telegram telegram) : _telegram = telegram;
  final Telegram _telegram;
  final Map<String, Command> _commands = {};

  void registerCommand(Command command) {
    _commands[command.name] = command;
  }

  void dispatch(Update data) {
    print(data.toJson());

    // юзер написал в личку, чтобы бот получил айди чата
    if (data.message.chat.type == 'private') {
      final user = LitUser(data.message.from);
      user.chatId = data.message.chat.id;
      _telegram.sendMessage(data.message.chat.id, "Спасибо! Обещаю не спамить :-)");
      return;
    }

    // у юзера какие-то кнопки
    if (data.message.reply_to_message != null) {
      ButtonCallbackController()
          .getCallbackForMessage(data.message)
          .run(data.message, _telegram);
      return;
    }

    // это какая-то команда, то есть сообщение со слеша
    var commandEntity = data.message.entityOf('bot_command');
    if (commandEntity != null) {
      var command = data.message.text.split('@').first.replaceFirst('/', '');
      if (_commands[command] != null) {
        _commands[command].run(data.message, _telegram);
      }
      return;
    }
  }
}
