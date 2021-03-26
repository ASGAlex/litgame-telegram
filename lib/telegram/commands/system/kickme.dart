// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class KickMeCmd extends JoinMeCmd {
  KickMeCmd();

  @override
  bool get system => false;

  @override
  String get name => 'kickme';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    LitGame game;
    if (message.chat.type == 'private') {
      var possibleGame = LitGame.findGameOfPlayer(message.chat.id);
      if (possibleGame == null) {
        throw 'Игра не найдена';
      }
      game = possibleGame;
    } else {
      game = LitGame.find(message.chat.id);
    }
    final me = LitUser(message.from);
    game.logic.add(KickFromGameEvent(me, me));
  }

  void sendKickMessage(LitGame game, LitUser user) {
    telegram.sendMessage(game.id, user.nickname + ' покидает игру');
  }

  @override
  ArgParser? getParser() => null;
}
