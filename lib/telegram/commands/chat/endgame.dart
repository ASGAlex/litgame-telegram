// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class EndGameCmd extends GameCommand {
  EndGameCmd();
  @override
  String get name => 'endgame';

  @override
  bool get system => false;

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    checkGameChat(message);
    final game = LitGame.find(message.chat.id);
    game.logic.add(GameEndEvent(LitUser(message.from).fromGame(game)));
  }

  @override
  ArgParser? getParser() => null;

  void afterGameEnd(MainProcess bloc, Transition transition) {
    telegram.sendMessage(bloc.game.id, 'Всё, наигрались!',
        reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
    deleteScheduledMessages(telegram);
  }
}

class StopGameCmd extends EndGameCmd {
  StopGameCmd();

  @override
  String get name => 'stopgame';
}
