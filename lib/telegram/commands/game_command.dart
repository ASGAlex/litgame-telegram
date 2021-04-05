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

  LitGame findGameByArguments() {
    final sGameChatId = arguments?['gci'];
    if (sGameChatId == null) throw 'команда запущена без указания ID игры';

    int gameChatId;
    if (sGameChatId is String) {
      gameChatId = int.parse(sGameChatId);
    } else if (sGameChatId is int) {
      gameChatId = sGameChatId;
    } else {
      throw 'неверный тип аргумента';
    }
    return LitGame.find(gameChatId);
  }

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
      parameters['gci'] = findGameByArguments().id.toString();
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
    if (existingGame != null) {
      telegram.getChat(existingGame.id).then((chat) {
        var chatName = chat.title ?? chat.id.toString();
        telegram.sendMessage(
            user.chatId,
            'Чтобы включиться в игру, нужно завершить текущую в чате "' +
                chatName +
                '"');
      });
    }
  }
}
