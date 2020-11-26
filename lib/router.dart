import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

class Router {
  Router(Telegram telegram) : _telegram = telegram;
  final Telegram _telegram;
  final Map<String, Command> _commands = {};

  void registerCommand(Command command) {
    _commands[command.name] = command;
  }

  void dispatch(Update data) {
    print(data.toJson());

    // юзер написал в личку, чтобы бот получил айди чата.
    if (data.message?.chat.type == 'private') {
      final user = LitUser(data.message.from);
      user.chatId = data.message.chat.id;
      _telegram
          .sendMessage(data.message.chat.id, 'Я запомнил тебя! Обещаю не спамить :-)')
          .then((value) {
        // LitUser.saveChatIdStorage();
      });
      return;
    }

    // это какая-то команда, то есть сообщение со слеша
    final commandName = _discoverCommandName(data);
    final cmd = _commands[commandName];
    if (cmd == null) return;
    if (data.callback_query == null && cmd.system) return;

    var message = data.message ?? data.callback_query?.message;
    if (message != null) {
      // FIXME: dirty hack
      if (data.callback_query?.from != null) {
        message.from = data.callback_query?.from;
      }
      if (data.callback_query != null) {
        var arguments = data.callback_query?.data.split(' ');
        final parser = cmd.getParser();
        cmd.arguments = parser?.parse(arguments);
      }
      cmd.run(message, _telegram);
    }
  }

  String _discoverCommandName(Update data) {
    var commandEntity = data.message?.entityOf('bot_command');
    var command = '';
    final query = data.callback_query;
    if (commandEntity == null && data.callback_query != null) {
      command = query.data.split(' ').first.replaceFirst('/', '');
    } else if (commandEntity != null) {
      command = data.message.text.split('@').first.replaceFirst('/', '');
    }
    return command;
  }
}
