// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class SetMasterCmd extends GameCommand {
  SetMasterCmd();

  @override
  bool get system => true;

  @override
  ArgParser getParser() => getGameBaseParser()..addOption('userId');

  @override
  String get name => 'setmaster';

  @override
  void run(Message message, TelegramEx telegram) {
    deleteScheduledMessages(telegram);
    final player = game.players[int.parse(arguments?['userId'])];
    player?.isGameMaster = true;
    if (player != null) {
      telegram.sendMessage(gameChatId,
          player.nickname + '(' + player.fullName + ') будет игромастером!');

      final cmd = Command.withArguments(() => SetOrderCmd(), {
        'gci': gameChatId.toString(),
        'userId': arguments?['userId'],
        'reset': ''
      });
      cmd.run(message, telegram);
    }
  }
}
