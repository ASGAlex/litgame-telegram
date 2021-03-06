// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

class StartGameCmd extends GameCommand with ReportMultipleGames {
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
    final me = LitUser(message.from, isAdmin: true);
    try {
      final game = LitGame.startNew(message.chat.id);
      game.logic.add(StartNewGameEvent(me));
    } catch (_) {
      sendPublicAlert(message.chat.id, me);
      sendPrivateDetailedAlert(me);
    }
  }

  @override
  ArgParser? getParser() => null;

  void afterGameStart(GameBloc bloc, Transition transition) {
    telegram
        .sendMessage(
            bloc.game.id,
            '=========================================\r\n'
            'Начинаем новую игру! \r\n'
            'ВНИМАНИЕ, с кем ещё не общались - напишите мне в личку, чтобы я тоже мог вам отправлять сообщения.\r\n'
            'У вас на планете дискриминация роботов, поэтому сам я вам просто так написать не смогу :-( \r\n'
            '\r\n'
            'Кто хочет поучаствовать?',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: StartGameCmd.BTN_YES, callback_data: '/joinme'),
                InlineKeyboardButton(
                    text: StartGameCmd.BTN_NO, callback_data: '/kickme')
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }
}
