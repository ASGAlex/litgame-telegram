// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

class JoinMeCmd extends GameCommand with ReportMultipleGames {
  JoinMeCmd();

  @override
  bool get system => true;

  @override
  String get name => 'joinme';

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    final game = LitGame.find(message.chat.id);
    final me = LitUser(message.from);
    game.logic.add(JoinGameEvent(me, me));
  }

  void sendChatIdRequest(LitGame game, LitUser user, TelegramEx telegram) {
    var text = user.nickname + ' подключился к игре!\r\n';
    user.registrationChecked.then((registered) {
      if (!registered) {
        text +=
            'Мы с тобой ещё не общались, напиши мне в личку, чтобы продолжить игру.\r\n';
      }
      telegram.sendMessage(game.id, text);
    });
  }

  void sendStatisticsToAdmin(LitGame game) {
    if (game.admin.noChatId) return;
    var text = '*В игре примут участие:*\r\n';
    late ReplyMarkup markup;
    for (var user in game.players.values) {
      text += ' - ' + user.nickname + ' (' + user.fullName + ')\r\n';
    }
    if (game.players.isEmpty) {
      text = '*что-то все расхотели играть*';
      markup = ReplyMarkup();
    } else {
      markup = InlineKeyboardMarkup(inline_keyboard: [
        [
          InlineKeyboardButton(
              text: 'Завершить набор игроков',
              callback_data:
                  FinishJoinCmd().buildCommandCall({'gci': game.id.toString()}))
        ]
      ]);
    }

    telegram
        .sendMessage(game.admin.chatId, text.escapeMarkdownV2(),
            parse_mode: 'MarkdownV2', reply_markup: markup)
        .then((message) {
      scheduleMessageDelete(message.chat.id, message.message_id);
    });
  }

  @override
  ArgParser? getParser() => null;
}
