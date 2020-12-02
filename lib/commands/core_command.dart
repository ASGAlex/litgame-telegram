import 'package:args/args.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

import '../telegram.dart';

abstract class Command {
  Command();

  String get name;

  bool get system => true;

  ArgResults? arguments;

  Command.args(this.arguments);

  void run(Message message, LitTelegram telegram);
  void reset() {
    arguments = null;
  }

  ArgParser? getParser();

  ArgParser getGameBaseParser() {
    var parser = ArgParser();
    parser.addOption('gameChatId');
    return parser;
  }

  LitGame get game {
    var gameChatId = arguments?['gameChatId'];
    if (arguments?['gameChatId'] is String) {
      gameChatId = int.parse(arguments?['gameChatId']);
    }
    var game = LitGame.find(gameChatId);
    if (game == null) throw 'В этом чате не играется ни одна игра';
    return game;
  }

  int? get gameChatId => (arguments?['gameChatId'] is String)
      ? int.parse(arguments?['gameChatId'])
      : arguments?['gameChatId'];

  @protected
  void checkGameChat(Message message) {
    if (message.chat.id > 0) {
      throw 'Эту команду надо не в личке запускать, а в чате с игроками ;-)';
    }
  }

  static final Map<int, List> _messagesToClean = {};

  void scheduleMessageDelete(int chatId, int messageId) {
    if (_messagesToClean[chatId] == null) {
      _messagesToClean[chatId] = [];
    }
    _messagesToClean[chatId]?.add(messageId);
  }

  void cleanScheduledMessages(Telegram telegram) {
    for (var msg in _messagesToClean.entries) {
      for (var message_id in msg.value) {
        telegram.deleteMessage(msg.key, message_id).catchError((error) {
          print(error);
        });
      }
    }
    _messagesToClean.clear();
  }

  @mustCallSuper
  String buildCommandCall([Map<String, String> parameters = const {}]) {
    var command = '/' + name;
    parameters.forEach((key, value) {
      if (key.contains(' ')) throw 'Invalid command key!';
      command += ' --' + key + ' ' + value;
    });
    return command;
  }
}
