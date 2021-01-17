// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/commands/pm/help.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

import 'models/game/user.dart';

class Router {
  Router(LitTelegram telegram) : _telegram = telegram;
  final LitTelegram _telegram;
  final Map<String, CommandConstructor> _commands = {};

  void registerCommand(CommandConstructor commandConstructor) {
    final cmd = commandConstructor();
    _commands[cmd.name] = commandConstructor;
  }

  Command? _buildCommand(String name) {
    var builder = _commands[name];
    if (builder == null) return null;
    return builder();
  }

  //TODO: move to separate class maybe?
  void _copyPMMessagesToGameChat(Message message, Telegram telegram) {
    final player = LitGame.findPlayerInExistingGames(message.chat.id);
    if (player != null && player.isCopyChatSet) {
      final gameChatId = player.currentGame?.chatId;
      if (gameChatId == null) {
        throw 'Player is in game, but currentGame.chatId is null!';
      }
      final text = 'Игрок ' +
          player.nickname +
          ' (' +
          player.fullName +
          ') пишет: \r\n' +
          message.text;
      telegram.sendMessage(gameChatId, text);
    }
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
    print(data.toJson());

    // юзер написал в личку, просто так или чтобы бот получил айди чата.
    if (data.message?.chat.type == 'private') {
      final user = LitUser(data.message.from);
      user.registrationChecked.then((registered) {
        if (!registered) {
          user.save();
          final help = ComplexCommand.withAction(() => HelpCmd(), 'firstRun');
          help.run(data.message, _telegram);
        }
        _copyPMMessagesToGameChat(data.message, _telegram);
      });
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
        if (data.callback_query == null && cmd.system) {
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
