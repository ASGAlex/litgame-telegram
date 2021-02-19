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
    initGameLogic(
        StartNewGame(message.chat.id, LitUser(message.from, isAdmin: true)));
  }

  @override
  ArgParser? getParser() => null;

  @override
  void stateLogic(GameState state) {
    if (state is InvitingGameState) {
      telegram
          .sendMessage(
              state.gameId,
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
    } else {
      telegram.sendMessage(message.chat.id,
          'Чтобы начать новую игру, нужно завершить начатую игру.');
      final existingGame = LitGame.findGameOfPlayer(message.from.id);
      if (existingGame != null) {
        telegram.getChat(existingGame.chatId).then((chat) {
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
}
