// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

mixin GameCmdMix on Command {
  static late TelegramEx _telegram;
  late final Message message;

  void initTeledart(Message message, TelegramEx tele) {
    this.message = message;
    _telegram = tele;
  }

  TelegramEx get telegram => _telegram;

  ArgParser getGameBaseParser() {
    var parser = ArgParser();
    parser.addOption('gci');
    return parser;
  }

  LitGame get game {
    var gameChatId = arguments?['gci'];
    if (arguments?['gci'] is String) {
      gameChatId = int.parse(arguments?['gci']);
    }
    if (gameChatId == null && message.chat.id < 0) {
      gameChatId = message.chat.id;
    }
    return LitGame.find(gameChatId);
  }

  int? get gameChatId => (arguments?['gci'] is String)
      ? int.parse(arguments?['gci'])
      : arguments?['gci'];

  @protected
  void checkGameChat(Message message) {
    if (message.chat.id > 0) {
      throw 'Эту команду надо не в личке запускать, а в чате с игроками ;-)';
    }
  }
}

abstract class GameCommand extends Command
    with GameCmdMix
    implements GameCmdMix {}

abstract class ComplexGameCommand extends ComplexCommand
    with GameCmdMix
    implements GameCmdMix {
  @override
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    if (parameters['gci'] == null) {
      parameters['gci'] = gameChatId.toString();
    }
    return super.buildAction(actionName, parameters);
  }
}

mixin ReportMultipleGames on GameCmdMix {
  void sendPublicAlert(int gameChatId, LitUser user) {
    telegram.sendMessage(
        gameChatId,
        user.nickname +
            ' играет в какой-то другой игре. Надо её сначала завершить или выйти.');
  }

  void sendPrivateDetailedAlert(LitUser user) {
    final existingGame = LitGame.findGameOfPlayer(user.chatId);
    telegram.getChat(existingGame?.id).then((chat) {
      var chatName = chat.title ?? chat.id.toString();
      telegram.sendMessage(
          user.chatId,
          'Чтобы включиться в игру, нужно завершить текущую в чате "' +
              chatName +
              '"');
    });
  }
}
