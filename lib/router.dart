import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';

import 'models/game/user.dart';

class Router {
  Router(LitTelegram telegram) : _telegram = telegram;
  final LitTelegram _telegram;
  final Map<String, Command> _commands = {};

  void registerCommand(Command command) {
    _commands[command.name] = command;
  }

  void dispatch(Update data) {
    print(data.toJson());

    // юзер написал в личку, чтобы бот получил айди чата.
    if (data.message?.chat.type == 'private') {
      final user = LitUser(data.message.from);
      user.registrationChecked.then((registered) {
        if (!registered) {
          _telegram.sendMessage(
              data.message.chat.id, 'Я запомнил тебя! Обещаю не спамить :-)');
          user.save();
        }
      });
    }

    // это какая-то команда, то есть сообщение со слеша
    final commandName = _discoverCommandName(data);
    var cmd = _commands[commandName];
    if (cmd == null) {
      cmd = RouterController().getScheduledCommand(data.message.chat.id);
      if (cmd == null) return;
      cmd.run(data.message, _telegram);
    } else {
      var message = data.message ?? data.callback_query?.message;
      if (message != null) {
        RouterController().clear(message.chat.id);
      }
      if (data.callback_query == null && cmd.system) return;

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

class RouterController {
  static final _controller = RouterController._instance();

  factory RouterController() => _controller;

  RouterController._instance();

  final Map<int, Command> _scheduledCommands = {};

  void willProcessNextMessageInChat(int chatId, Command cmd) {
    _scheduledCommands[chatId] = cmd;
  }

  Command? getScheduledCommand(int chatId) => _scheduledCommands[chatId];

  void clear(int chatId) {
    _scheduledCommands.remove(chatId);
  }
}
