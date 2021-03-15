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
    game.logic.add(StopGameEvent(LitUser(message.from)));
  }

  @override
  ArgParser? getParser() => null;

  void afterGameEnd(GameBloc bloc, Transition transition) {
    telegram.sendMessage(bloc.game.id, 'Всё, наигрались!',
        reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
    deleteScheduledMessages(telegram);
  }
}
