// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

class FinishJoinCmd extends GameCommand {
  FinishJoinCmd();

  @override
  bool get system => true;

  @override
  String get name => 'finishjoin';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    game.logic.add(FinishJoinEvent(LitUser(message.from)));
  }

  @override
  ArgParser getParser() => getGameBaseParser();

  @override
  void onTransition(Bloc bloc, Transition transition) {
    // TODO: implement onTransition
  }
}
