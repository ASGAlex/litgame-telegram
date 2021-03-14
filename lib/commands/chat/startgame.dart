// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

class StartGameCmd extends GameCommand {
  static const String BTN_YES = 'Участвую!';
  static const String BTN_NO = 'Неть...';

  StartGameCmd();

  @override
  String get name => 'startgame';

  @override
  bool get system => false;

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    checkGameChat(message);
    try {
      final game = LitGame.startNew(message.chat.id);
      game.logic.add(StartNewGameEvent(LitUser(message.from, isAdmin: true)));
    } catch (_) {
      telegram.sendMessage(message.chat.id,
          'Чтобы начать новую игру, нужно завершить начатую игру.');
      final existingGame = LitGame.findGameOfPlayer(message.from.id);
      if (existingGame != null) {
        telegram.getChat(existingGame.id).then((chat) {
          var chatName = chat.title ?? chat.id.toString();
          telegram.sendMessage(
              message.from.id,
              'Чтобы начать новую игру, нужно завершить текущую в чате "' +
                  chatName +
                  '"');
        });
      }
    }
  }

  @override
  ArgParser? getParser() => null;

  @override
  void onTransition(Bloc bloc, Transition transition) {
    // TODO: implement onTransition
  }
}
