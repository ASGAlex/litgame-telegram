// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

class JoinMeCmd extends GameCommand {
  JoinMeCmd();

  @override
  bool get system => true;

  @override
  String get name => 'joinme';

  @override
  void run(Message message, TelegramEx telegram) {
    final user = LitUser(message.from);
    gameLogic.listen((state) {
      if (state is InvitingGameState) {
        if (state.lastInviteResult == null) return;
        final game = state.game;
        if (game == null) {
          throw 'В этом чате нет запущенных игр';
        }
        _sendChatIdRequest(message, user, telegram);

        if (state.lastInviteResult == true) {
          sendStatisticsToAdmin(game, telegram, message.chat.id);
        } else {
          final existingGame = LitGame.findGameOfPlayer(user.chatId);
          if (existingGame != game) {
            telegram.sendMessage(
                message.chat.id,
                user.nickname +
                    ' играет в какой-то другой игре. Надо её сначала завершить.');
            telegram.getChat(existingGame?.chatId).then((chat) {
              var chatName = chat.title ?? chat.id.toString();
              telegram.sendMessage(
                  user.chatId,
                  'Чтобы начать новую игру, нужно завершить текущую в чате "' +
                      chatName +
                      '"');
            });
          }
        }
      }
    });

    gameLogic.add(JoinNewGame(message.chat.id, user));

    gameLogic.close();
  }

  void _sendChatIdRequest(Message message, LitUser user, TelegramEx telegram) {
    var text = user.nickname + ' подключился к игре!\r\n';
    user.registrationChecked.then((registered) {
      if (!registered) {
        text +=
            'Мы с тобой ещё не общались, напиши мне в личку, чтобы продолжить игру.\r\n';
      }
      telegram.sendMessage(message.chat.id, text);
    });
  }

  @protected
  void sendStatisticsToAdmin(
      LitGame game, TelegramEx telegram, int gameChatId) {
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
              callback_data: FinishJoinCmd()
                  .buildCommandCall({'gci': gameChatId.toString()}))
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
