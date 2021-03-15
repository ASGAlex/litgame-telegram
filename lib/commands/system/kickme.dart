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
    game.logic.add(KickFromGameEvent(LitUser(message.from)));
  }

  void sendKickMessage(LitGame game, LitUser user) {
    telegram.sendMessage(game.id, user.nickname + ' покидает игру');
  }

  @override
  ArgParser? getParser() => null;
}
