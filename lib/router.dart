// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/commands/middleware.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

import 'models/game/user.dart';

class Router {
  Router(LitTelegram telegram) : _telegram = telegram;
  final LitTelegram _telegram;
  final Map<String, CommandConstructor> _commands = {};
  final List<MiddlewareConstructor> _middleware = [];

  void registerCommand(CommandConstructor commandConstructor) {
    final cmd = commandConstructor();
    _commands[cmd.name] = commandConstructor;
  }

  void registerMiddleware(MiddlewareConstructor commandConstructor) {
    _middleware.add(commandConstructor);
  }

  Command? _buildCommand(String name) {
    var builder = _commands[name];
    if (builder == null) return null;
    return builder();
  }

  //TODO: move to separate class maybe?
  void _copyGameChatMessagesToPM(Message message, Telegram telegram) {
    final game = LitGame.find(message.chat.id);
    if (game == null) return;
    if (!game.players.containsKey(message.from.id)) return;
    final messageAuthor = LitUser(message.from);
    final baseText = 'Игрок ' +
        messageAuthor.nickname +
        '(' +
        messageAuthor.fullName +
        ') пишет: \r\n';
    for (var player in game.players.entries) {
      if (player.value.telegramUser.id == message.from.id) continue;
      if (!player.value.isCopyChatSet) continue;

      telegram.sendMessage(player.value.chatId, baseText + message.text);
    }
  }

  void dispatch(Update data) {
    for (var builder in _middleware) {
      var cmd = builder();
      cmd.handle(data, _telegram);
    }

    var message = data.message ?? data.callback_query?.message;
    if (message == null) return;

    Command? cmd;
    cmd = RouterController().getScheduledCommand(message.chat.id);

    if (cmd != null) {
      RouterController().clear(message.chat.id);
      cmd.run(message, _telegram);
    } else {
      final commandName = _discoverCommandName(data);
      cmd = _buildCommand(commandName);
      if (cmd != null) {
        RouterController().clear(message.chat.id);
        if (!(data.callback_query == null && cmd.system)) {
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
          return;
        }
      }
      if (message.chat.type != 'private') {
        _copyGameChatMessagesToPM(message, _telegram);
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
