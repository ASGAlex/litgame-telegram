// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class KickMeCmd extends JoinMeCmd {
  KickMeCmd();

  @override
  bool get system => true;

  @override
  String get name => 'kickme';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    initGameLogic(KickFromNewGame(message.chat.id, LitUser(message.from)));
  }

  @override
  ArgParser? getParser() => null;

  @override
  void stateLogic(GameState state) {
    if (state is NoGame) {
      telegram.sendMessage(message.chat.id, 'Всё, наигрались!');
    } else if (state is InvitingGameState) {
      sendStatisticsToAdmin(state.game, telegram, message.chat.id);
    }
  }
}
