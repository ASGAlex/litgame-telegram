// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class GameFlowCmd extends ComplexGameCommand
    with ImageSender, EndTurn, CopyChat {
  GameFlowCmd();

  @override
  ArgParser getParser() =>
      super.getParser()..addOption('gci')..addOption('cid');

  @override
  bool get system => true;

  @override
  String get name => 'gf';

  LitGame get game => findGameByArguments();

  @override
  Map<String, CmdAction> get actionMap => {
        'start': onGameStart,
        'select-generic': onSelectCard,
        'select-place': onSelectCard,
        'select-person': onSelectCard,
        'next-turn': onNextTurn,
      };

  @override
  // ignore: must_call_super
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);

    final game = findGameByArguments();
    try {
      if (game.logic.bpGame.state.runtimeType != FlowPausedState) {
        super.run(message, telegram);
      }
    } catch (error) {
      print(error);
    }
  }

  @deprecated
  void onGameStart(Message message, TelegramEx telegram) {}

  void onNextTurn(Message message, TelegramEx telegram) {
    game.logic.add(GameFlowNextTurnEvent(LitUser(message.from).fromGame(game)));
  }

  void printCardSelectionMessages() {
    deleteScheduledMessages(telegram);
    telegram.sendMessage(
        game.id,
        'Ходит ' +
            game.gameFlow.currentUser.nickname +
            '(' +
            game.gameFlow.currentUser.fullName +
            ')');

    copyChat((chatId, _) {
      if (game.gameFlow.currentUser.chatId == chatId) return;
      telegram.sendMessage(
          chatId,
          'Ходит ' +
              game.gameFlow.currentUser.nickname +
              '(' +
              game.gameFlow.currentUser.fullName +
              ')');
    }, game);

    telegram
        .sendMessage(game.gameFlow.currentUser.chatId, 'Тянем карту!',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: 'Общая',
                    callback_data: buildAction('select-generic')),
                InlineKeyboardButton(
                    text: 'Место', callback_data: buildAction('select-place')),
                InlineKeyboardButton(
                    text: 'Персонаж',
                    callback_data: buildAction('select-person')),
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  void onSelectCard(Message message, TelegramEx telegram) {
    final sType = action.replaceAll('select-', '');
    game.logic.add(
        GameFlowCardSelectedEvent(LitUser(message.from).fromGame(game), sType));
  }

  void printStoryTellMode(Card card) {
    sendImage(game.gameFlow.currentUser.chatId, card.imgUrl, card.name, false)
        .then((value) {
      sendEndTurn(game.gameFlow);
    });
    sendImage(game.id, card.imgUrl, card.name, false);
    copyChat((chatId, _) {
      if (game.gameFlow.currentUser.chatId == chatId) return;
      sendImage(chatId, card.imgUrl, card.name, false);
    }, game);
  }

  void printGameStartMessage(LitGame game) {
    telegram.sendMessage(game.id, 'Начинаем игру!');

    copyChat((chatId, _) {
      telegram.sendMessage(chatId, 'Начинаем игру!');
    }, game);
  }

  void printCardsForMasterFirstTurn(List<Card> cards, TelegramEx telegram) {
    telegram.sendMessage(
        game.id,
        'Ходит ' +
            game.gameFlow.currentUser.nickname +
            '(' +
            game.gameFlow.currentUser.fullName +
            ')');

    copyChat((chatId, _) {
      if (game.gameFlow.currentUser.chatId == chatId) return;
      telegram.sendMessage(
          chatId,
          'Ходит ' +
              game.gameFlow.currentUser.nickname +
              '(' +
              game.gameFlow.currentUser.fullName +
              ')');
    }, game);

    if (cards.length < 3) throw 'Карт для старта игры должно быть три!';
    var cGeneric = cards[0];
    var cPlace = cards[1];
    var cPerson = cards[2];
    sendImage(game.gameFlow.currentUser.chatId, cGeneric.imgUrl, cGeneric.name,
            false)
        .then((value) {
      sendImage(game.gameFlow.currentUser.chatId, cPlace.imgUrl, cPlace.name,
              false)
          .then((value) {
        sendImage(game.gameFlow.currentUser.chatId, cPerson.imgUrl,
                cPerson.name, false)
            .then((value) {
          sendEndTurn(game.gameFlow);
        });
      });
    });

    sendImage(game.id, cGeneric.imgUrl, cGeneric.name, false).then((value) {
      sendImage(game.id, cPlace.imgUrl, cPlace.name, false).then((value) {
        sendImage(game.id, cPerson.imgUrl, cPerson.name, false);
      });
    });

    copyChat((chatId, _) {
      if (game.gameFlow.currentUser.chatId == chatId) return;
      sendImage(chatId, cGeneric.imgUrl, cGeneric.name, false).then((value) {
        sendImage(chatId, cPlace.imgUrl, cPlace.name, false).then((value) {
          sendImage(chatId, cPerson.imgUrl, cPerson.name, false);
        });
      });
    }, game);
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {}
}
