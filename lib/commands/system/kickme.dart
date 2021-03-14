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

  @override
  ArgParser? getParser() => null;

  @override
  void onTransition(Bloc bloc, Transition transition) {
    // TODO: implement onTransition
  }
}
