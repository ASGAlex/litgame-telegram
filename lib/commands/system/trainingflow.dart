// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class TrainingFlowCmd extends ComplexGameCommand
    with ImageSender, EndTurn, CopyChat {
  TrainingFlowCmd();

  @override
  bool get system => true;

  @override
  ArgParser getParser() =>
      super.getParser()..addOption('gci')..addOption('cid');

  @override
  Map<String, CmdAction> get actionMap => {
        'start': onTrainingStart,
        'next-turn': onNextTurn,
        'end': onTrainingEnd,
      };

  @override
  String get name => 'tf';

  late GameFlow gameFlow;
  late TrainingFlow trainingFlow;
  bool firstStep = false;

  @override
  void run(Message message, TelegramEx telegram) async {
    deleteScheduledMessages(telegram);
    initTeledart(message, telegram);
    initGameLogic();
    super.run(message, telegram);
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    // TODO: implement onNoAction
  }

  void onTrainingStart(Message message, TelegramEx telegram) {
    const litMsg = 'Небольшая разминка!\r\n'
        'Сейчас каждому из игроков будет выдаваться случайная карта из колоды,'
        'и нужно будет по ней рассказать что-то, что связано с миром/темой, '
        'на которую вы собираетесь играть.\r\n'
        'Это позволит немного разогреть мозги, вспомнить забытые факты и "прокачать"'
        'менее подготовленных к игре товарищей.\r\n';
    telegram.sendMessage(game.chatId, litMsg);
    final msgToAdminIsCopied = copyChat((chatId, completer) {
      final future = telegram.sendMessage(chatId, litMsg);
      if (chatId == game.master.chatId) {
        future.then((value) {
          completer.complete();
        });
      }
    });

    msgToAdminIsCopied.then((value) {
      telegram.sendMessage(
          game.master.chatId, 'Когда решишь, что разминки хватит - жми сюда!',
          reply_markup: InlineKeyboardMarkup(inline_keyboard: [
            [
              InlineKeyboardButton(
                  text: 'Завершить разминку', callback_data: buildAction('end'))
            ]
          ]));
      firstStep = true;
      onNextTurn(message, telegram);
    });
  }

  void onNextTurn(Message message, TelegramEx telegram) {
    gameLogic.add(NextTurnTraining(
        game.chatId, LitUser(message.from), arguments?['cid']));
  }

  void onTrainingEnd(Message message, TelegramEx telegram) {
    gameLogic.add(
        StartGameEvent(game.chatId, LitUser(message.from), arguments?['cid']));
  }

  @override
  void stateLogic(GameState state) {
    if (state is TrainingFlowState) {
      final card = state.flow.getCard();
      final cardMsg = card.name +
          '\r\n' +
          'Ходит ' +
          state.flow.currentUser.nickname +
          '(' +
          state.flow.currentUser.fullName +
          ')';
      sendImage(game.chatId, card.imgUrl, cardMsg, false);
      copyChat((chatId, _) {
        if (state.flow.currentUser.chatId == chatId) return;
        sendImage(chatId, card.imgUrl, cardMsg, false);
      });

      sendImage(state.flow.currentUser.chatId, card.imgUrl, card.name, false)
          .then((value) {
        sendEndTurn(state.flow);
      });
    } else if (state is GFMaster3CardStoryTellState) {
      const litMsg = 'Разминку закончили, все молодцы!\r\n'
          'Сейчас таки начнём играть :-)';
      final endMessageSent = telegram.sendMessage(game.chatId, litMsg);
      copyChat((chatId, _) {
        telegram.sendMessage(chatId, litMsg);
      });
      final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'start',
          {'gci': game.chatId.toString(), 'cid': state.flow.collectionId});
      endMessageSent.then((value) {
        cmd.run(message, telegram);
      });
    }
  }
}
