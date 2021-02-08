// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class SetOrderCmd extends GameCommand {
  SetOrderCmd();

  @override
  ArgParser? getParser() => getGameBaseParser()..addOption('userId')..addOption('reset');

  @override
  String get name => 'setorder';

  @override
  void run(Message message, TelegramEx telegram) {
    deleteScheduledMessages(telegram);
    if (arguments?['reset'] == true) {
      game.playersSorted.clear();
      game.playersSorted.add(LinkedUser(game.master));
      telegram
          .sendMessage(message.chat.id,
              'В каком порядке будут ходить игроки:\r\n' + _getSortedUsersListText(),
              reply_markup: InlineKeyboardMarkup(inline_keyboard: getSortButtons()))
          .then((msg) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      });
      return;
    }

    final userId = int.parse(arguments?['userId']);
    final user = game.players[userId];
    if (user != null) {
      game.playersSorted.add(LinkedUser(user));
    }

    if (game.playersSorted.length == game.players.length) {
      telegram
          .sendMessage(
              message.chat.id, 'Игроки отсортированы:\r\n' + _getSortedUsersListText(),
              reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                [
                  InlineKeyboardButton(
                      text: 'Играем!',
                      // callback_data: GameFlowCmd.args(arguments).buildAction('start')),
                      callback_data: SetCollectionCmd()
                          .buildAction('list', {'gci': gameChatId.toString()})),
                  InlineKeyboardButton(
                      text: 'Отсортировать заново',
                      callback_data:
                          buildCommandCall({'gci': gameChatId.toString(), 'reset': ''}))
                ]
              ]))
          .then((msg) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      });
    } else {
      telegram
          .sendMessage(message.chat.id,
              'В каком порядке будут ходить игроки:\r\n' + _getSortedUsersListText(),
              reply_markup: InlineKeyboardMarkup(inline_keyboard: getSortButtons()))
          .then((msg) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      });
    }
  }

  String _getSortedUsersListText() {
    if (game.playersSorted.isEmpty) {
      return '';
    }

    LinkedUser? sortedUser = game.playersSorted.first;
    var usersList = '';
    var i = 1;
    do {
      if (sortedUser != null) {
        usersList += i.toString() +
            ' ' +
            sortedUser.user.nickname +
            '(' +
            sortedUser.user.fullName +
            ')\r\n';
      }
      sortedUser = sortedUser?.next;
      i++;
    } while (sortedUser != null);
    return usersList;
  }

  List<List<InlineKeyboardButton>> getSortButtons() {
    var usersToSelect = <List<InlineKeyboardButton>>[];
    game.players.forEach((key, user) {
      var skip = false;
      game.playersSorted.forEach((entry) {
        if (entry.user == user) skip = true;
      });
      if (skip) return;
      usersToSelect.add([
        InlineKeyboardButton(
            text: user.nickname + '(' + user.fullName + ')',
            callback_data: buildCommandCall({
              'gci': game.chatId.toString(),
              'userId': user.telegramUser.id.toString()
            }))
      ]);
    });
    return usersToSelect;
  }
}
