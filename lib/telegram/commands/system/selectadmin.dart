// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class SelectAdminCmd extends GameCommand {
  SelectAdminCmd();

  @override
  bool get system => true;

  @override
  ArgParser getParser() => getGameBaseParser()..addOption('userId');

  @override
  String get name => 'selectadmin';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    final game = findGameByArguments();
    final admin = game.players[int.parse(arguments?['userId'])];
    if (admin == null) {
      throw 'Ни один игрок не выбран в качестве админа игры!';
    }
    deleteScheduledMessages(telegram);
    telegram.sendMessage(game.id,
        admin.nickname + '(' + admin.fullName + ') будет новым админом!');
    var me = game.players[message.from.id];
    me ??= LitUser(message.from);
//    game.logic.add(SelectAdminEvent(me, admin));
  }

  void showSelectionDialogToAdmin(LitGame game, LitUser lastAdmin,
      [bool clear = true]) {
    if (clear) {
      deleteScheduledMessages(telegram);
    }
    final keyboard = <List<InlineKeyboardButton>>[];
    game.players.values.forEach((player) {
      if (!player.isAdmin) {
        var text = player.nickname + ' (' + player.fullName + ')';
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
      }
    });

    telegram
        .sendMessage(lastAdmin.chatId, 'Выберите нового админа игры: ',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: keyboard))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }
}
