import 'package:args/args.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

abstract class Command {
  String get name;

  bool get system => true;

  ArgResults? arguments;

  void run(
    Message message,
    Telegram telegram,
  );

  ArgParser? getParser();

  ArgParser getBaseParser() {
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
    return game ?? LitGame(-1);
  }

  int? get gameChatId => (arguments?['gameChatId'] is String)
      ? int.parse(arguments?['gameChatId'])
      : arguments?['gameChatId'];

  @protected
  void checkGameChat(Message message) {
    if (message.chat == null) {
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
}
