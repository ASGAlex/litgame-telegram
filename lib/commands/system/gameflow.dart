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
    super.run(message, telegram);
  }

  void onGameStart(Message message, TelegramEx telegram) {
    telegram.sendMessage(
        game.chatId,
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
    });

    var cGeneric = game.gameFlow.getCard(CardType.generic);
    var cPlace = game.gameFlow.getCard(CardType.place);
    var cPerson = game.gameFlow.getCard(CardType.person);
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

    sendImage(game.chatId, cGeneric.imgUrl, cGeneric.name, false).then((value) {
      sendImage(game.chatId, cPlace.imgUrl, cPlace.name, false).then((value) {
        sendImage(game.chatId, cPerson.imgUrl, cPerson.name, false);
      });
    });

    copyChat((chatId, _) {
      if (game.gameFlow.currentUser.chatId == chatId) return;
      sendImage(chatId, cGeneric.imgUrl, cGeneric.name, false).then((value) {
        sendImage(chatId, cPlace.imgUrl, cPlace.name, false).then((value) {
          sendImage(chatId, cPerson.imgUrl, cPerson.name, false);
        });
      });
    });
  }

  void onNextTurn(Message message, TelegramEx telegram) {
    game.logic.addEvent(GameEventType.gameFlowNextTurn, LitUser(message.from));
  }

  void printCardSelectionMessages() {
    deleteScheduledMessages(telegram);
    telegram.sendMessage(
        game.chatId,
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
    });

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
    game.logic.addEvent(
        GameEventType.gameFlowCardSelected, LitUser(message.from), sType);
    //gameLogic.add(GameStoryTellStartEvent(game.chatId, LitUser(message.from)));
  }

  void printStoryTellMode(Card card) {
    sendImage(game.gameFlow.currentUser.chatId, card.imgUrl, card.name, false)
        .then((value) {
      sendEndTurn(game.gameFlow);
    });
    sendImage(game.chatId, card.imgUrl, card.name, false);
    copyChat((chatId, _) {
      if (game.gameFlow.currentUser.chatId == chatId) return;
      sendImage(chatId, card.imgUrl, card.name, false);
    });
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {}

  @override
  void stateLogic(GameState state) {}
}
