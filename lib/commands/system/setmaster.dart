// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class SetMasterCmd extends GameCommand {
  SetMasterCmd();

  @override
  bool get system => true;

  @override
  ArgParser getParser() => getGameBaseParser()..addOption('userId');

  @override
  String get name => 'setmaster';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    final master = game.players[int.parse(arguments?['userId'])];
    if (master == null) {
      throw 'Ни один игрок не выбран в качестве мастера игры!';
    }
    deleteScheduledMessages(telegram);
    telegram.sendMessage(gameChatId,
        master.nickname + '(' + master.fullName + ') будет игромастером!');
    var me = game.players[message.from.id];
    me ??= LitUser(message.from);
    game.logic.add(SelectMasterEvent(me, master));
  }

  void showSelectionDialogToAdmin(LitGame game) {
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
            callback_data: buildCommandCall({
              'gci': game.id.toString(),
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
}
