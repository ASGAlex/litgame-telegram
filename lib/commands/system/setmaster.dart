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
    initTeledart(message, telegram);
    final master = game.players[int.parse(arguments?['userId'])];
    if (master == null) {
      throw 'Ни один игрок не выбран в качестве мастера игры!';
    }
    deleteScheduledMessages(telegram);
    telegram.sendMessage(
        gameChatId,
        game.master.nickname +
            '(' +
            game.master.fullName +
            ') будет игромастером!');
    game.logic
        .addEvent(GameEventType.selectMaster, LitUser(message.from), master);
  }

  @override
  void stateLogic(GameState state) {}
}
