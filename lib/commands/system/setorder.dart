import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class SetOrderCmd extends Command {
  @override
  ArgParser? getParser() {
    final parser = getBaseParser();
    parser.addOption('userId');
    parser.addFlag('reset');
    return parser;
  }

  @override
  String get name => 'setorder';

  @override
  void run(Message message, Telegram telegram) {
    cleanScheduledMessages(telegram);
    if (arguments?['reset'] == true) {
      game.playersSorted.clear();
      telegram
          .sendMessage(message.chat.id,
              'В каком порядке будут ходить игроки:\r\n' + _getSortedUsersListText(),
              reply_markup:
                  InlineKeyboardMarkup(inline_keyboard: SetOrderCmd.getSortButtons(game)))
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
                      callback_data:
                          '/startgameflow --gameChatId=' + gameChatId.toString()),
                  InlineKeyboardButton(
                      text: 'Отсортировать заново',
                      callback_data:
                          '/setorder --gameChatId=' + gameChatId.toString() + ' --reset')
                ]
              ]))
          .then((msg) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      });
    } else {
      telegram
          .sendMessage(message.chat.id,
              'В каком порядке будут ходить игроки:\r\n' + _getSortedUsersListText(),
              reply_markup:
                  InlineKeyboardMarkup(inline_keyboard: SetOrderCmd.getSortButtons(game)))
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

  static List<List<InlineKeyboardButton>> getSortButtons(LitGame game) {
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
            callback_data: '/setorder --gameChatId=' +
                game.chatId.toString() +
                ' --userId=' +
                user.telegramUser.id.toString())
      ]);
    });
    return usersToSelect;
  }
}
