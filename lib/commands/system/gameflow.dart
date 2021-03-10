// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class GameFlowCmd extends ComplexGameCommand
    with ImageSender, EndTurn, CopyChat {
  GameFlowCmd();

  @override
  ArgParser getParser() =>
      super.getParser()..addOption('gci')..addOption('cid');

  GameFlow get flow {
    final state = gameLogic.state;
    state as GFMaster3CardStoryTellState;
    return state.flow;
  }

  @override
  bool get system => true;

  @override
  String get name => 'gf';

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
    initGameLogic();

    super.run(message, telegram);
  }

  void onGameStart(Message message, TelegramEx telegram) {
    if (flow.currentUser.isGameMaster && flow.turnNumber == 1) {
      telegram.sendMessage(
          flow.game.chatId,
          'Ходит ' +
              flow.currentUser.nickname +
              '(' +
              flow.currentUser.fullName +
              ')');

      copyChat((chatId, _) {
        if (flow.currentUser.chatId == chatId) return;
        telegram.sendMessage(
            chatId,
            'Ходит ' +
                flow.currentUser.nickname +
                '(' +
                flow.currentUser.fullName +
                ')');
      });

      var cGeneric = flow.getCard(CardType.generic);
      var cPlace = flow.getCard(CardType.place);
      var cPerson = flow.getCard(CardType.person);
      sendImage(flow.currentUser.chatId, cGeneric.imgUrl, cGeneric.name, false)
          .then((value) {
        sendImage(flow.currentUser.chatId, cPlace.imgUrl, cPlace.name, false)
            .then((value) {
          sendImage(
                  flow.currentUser.chatId, cPerson.imgUrl, cPerson.name, false)
              .then((value) {
            sendEndTurn(flow);
          });
        });
      });

      sendImage(flow.game.chatId, cGeneric.imgUrl, cGeneric.name, false)
          .then((value) {
        sendImage(flow.game.chatId, cPlace.imgUrl, cPlace.name, false)
            .then((value) {
          sendImage(flow.game.chatId, cPerson.imgUrl, cPerson.name, false);
        });
      });

      copyChat((chatId, _) {
        if (flow.currentUser.chatId == chatId) return;
        sendImage(chatId, cGeneric.imgUrl, cGeneric.name, false).then((value) {
          sendImage(chatId, cPlace.imgUrl, cPlace.name, false).then((value) {
            sendImage(chatId, cPerson.imgUrl, cPerson.name, false);
          });
        });
      });
    } else {
      throw 'Invalid game start process';
    }
  }

  void onNextTurn(Message message, TelegramEx telegram) {
    gameLogic.add(NextTurnGameEvent(game.chatId, LitUser(message.from)));
  }

  void onSelectCard(Message message, TelegramEx telegram) {
    gameLogic.add(GameStoryTellStartEvent(game.chatId, LitUser(message.from)));
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {}

  @override
  void stateLogic(GameState state) {
    if (state is GameFlowCardSelectionState) {
      deleteScheduledMessages(telegram);
      telegram.sendMessage(
          flow.game.chatId,
          'Ходит ' +
              flow.currentUser.nickname +
              '(' +
              flow.currentUser.fullName +
              ')');

      copyChat((chatId, _) {
        if (flow.currentUser.chatId == chatId) return;
        telegram.sendMessage(
            chatId,
            'Ходит ' +
                flow.currentUser.nickname +
                '(' +
                flow.currentUser.fullName +
                ')');
      });

      telegram
          .sendMessage(flow.currentUser.chatId, 'Тянем карту!',
              reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                [
                  InlineKeyboardButton(
                      text: 'Общая',
                      callback_data: buildAction('select-generic')),
                  InlineKeyboardButton(
                      text: 'Место',
                      callback_data: buildAction('select-place')),
                  InlineKeyboardButton(
                      text: 'Персонаж',
                      callback_data: buildAction('select-person')),
                ]
              ]))
          .then((msg) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      });
    } else if (state is GameFlowCardChosenState) {
      deleteScheduledMessages(telegram);
      var sType = action.replaceAll('select-', '');
      var type = CardType.generic.getTypeByName(sType);
      var card = flow.getCard(type);
      sendImage(flow.currentUser.chatId, card.imgUrl, card.name, false)
          .then((value) {
        sendEndTurn(flow);
      });
      sendImage(flow.game.chatId, card.imgUrl, card.name, false);
      copyChat((chatId, _) {
        if (flow.currentUser.chatId == chatId) return;
        sendImage(chatId, card.imgUrl, card.name, false);
      });
    }
  }
}
