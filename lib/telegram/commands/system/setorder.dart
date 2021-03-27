// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class SetOrderCmd extends GameCommand {
  SetOrderCmd();

  @override
  bool get system => true;

  @override
  ArgParser? getParser() =>
      getGameBaseParser()..addOption('userId')..addOption('reset');

  @override
  String get name => 'setorder';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    final game = findGameByArguments();
    final me = LitUser(message.from).fromGame(game);

    deleteScheduledMessages(telegram);
    final userId = arguments?['userId'];
    if (arguments?['reset'] != null) {
      game.logic.add(ResetPlayersOrderEvent(me));
    } else if (userId != null) {
      final uid = int.parse(userId);
      final user = game.players[uid];
      if (user != null) {
        game.logic.add(SortPlayerEvent(me, user));
      }
    }
  }

  void showSelectOrderDialog(LitGame game) {
    telegram
        .sendMessage(
            game.admin.chatId,
            'В каком порядке будут ходить игроки:\r\n' +
                _getSortedUsersListText(game),
            reply_markup:
                InlineKeyboardMarkup(inline_keyboard: _getSortButtons(game)))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  void showSortFinishedMessage(LitGame game) {
    telegram
        .sendMessage(game.admin.chatId,
            'Игроки отсортированы:\r\n' + _getSortedUsersListText(game),
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: 'Играем!',
                    callback_data: SetCollectionCmd()
                        .buildAction('list', {'gci': game.id.toString()})),
                InlineKeyboardButton(
                    text: 'Отсортировать заново',
                    callback_data: buildCommandCall(
                        {'gci': game.id.toString(), 'reset': ''}))
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  String _getSortedUsersListText(LitGame game) {
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

  List<List<InlineKeyboardButton>> _getSortButtons(LitGame game) {
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
              'gci': game.id.toString(),
              'userId': user.telegramUser.id.toString()
            }))
      ]);
    });
    return usersToSelect;
  }
}
