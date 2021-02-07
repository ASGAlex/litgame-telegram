// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

class FinishJoinCmd extends GameCommand {
  FinishJoinCmd();

  @override
  String get name => 'finishjoin';

  @override
  void run(Message message, TelegramEx telegram) {
    if (message.chat.id != game.admin.chatId) {
      telegram.sendMessage(message.chat.id, 'Не ты админ текущей игры!');
      return;
    }

    deleteScheduledMessages(telegram);
    final keyboard = <List<InlineKeyboardButton>>[];
    game.players.values.forEach((player) {
      var text = player.nickname + ' (' + player.fullName + ')';
      if (player.isAdmin) {
        text += '(admin)';
      }
      if (player.isGameMaster) {
        text += '(master)';
      }

      keyboard.add([
        InlineKeyboardButton(
            text: text,
            callback_data: SetMasterCmd().buildCommandCall({
              'gci': gameChatId.toString(),
              'userId': player.telegramUser.id.toString()
            }))
      ]);
    });

    telegram
        .sendMessage(game.admin.chatId, 'Выберите мастера игры: ',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: keyboard))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  @override
  ArgParser getParser() => getGameBaseParser();
}
