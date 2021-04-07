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
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    final game = findGameByArguments();
    try {
      if (game.logic.bpTraining.state.runtimeType != FlowPausedState) {
        deleteScheduledMessages(telegram);
        super.run(message, telegram);
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    // TODO: implement onNoAction
  }

  void onTrainingStart(Message message, TelegramEx telegram) {
    final game = findGameByArguments();
    game.logic.add(TrainingStartEvent(
        LitUser(message.from).fromGame(game), arguments?['cid']));
  }

  void onNextTurn(Message message, TelegramEx telegram) {
    final game = findGameByArguments();
    game.logic.add(TrainingNextTurnEvent(LitUser(message.from).fromGame(game)));
  }

  void onTrainingEnd(Message message, TelegramEx telegram) {
    final game = findGameByArguments();
    game.logic.add(TrainingFinishedEvent(LitUser(message.from).fromGame(game)));
  }

  Future showTrainingDescriptionMessage(LitGame game) {
    const litMsg = 'Небольшая разминка!\r\n'
        'Сейчас каждому из игроков будет выдаваться случайная карта из колоды,'
        'и нужно будет по ней рассказать что-то, что связано с миром/темой, '
        'на которую вы собираетесь играть.\r\n'
        'Это позволит немного разогреть мозги, вспомнить забытые факты и "прокачать"'
        'менее подготовленных к игре товарищей.\r\n';
    telegram.sendMessage(game.id, litMsg);
    return copyChat((chatId, completer) {
      final future = telegram.sendMessage(chatId, litMsg);
      if (chatId == game.master.chatId) {
        future.then((value) {
          completer.complete();
        });
      }
    }, game);
  }

  Future showTrainingEndButtonToAdmin(LitGame game) {
    return telegram.sendMessage(
        game.master.chatId, 'Когда решишь, что разминки хватит - жми сюда!',
        reply_markup: InlineKeyboardMarkup(inline_keyboard: [
          [
            InlineKeyboardButton(
                text: 'Завершить разминку',
                callback_data: buildAction('end', {'gci': game.id.toString()}))
          ]
        ]));
  }

  void showNextTurnMessage(LitGame game, TelegramEx tele) async {
    telegram = tele;
    final flow = await game.trainingFlow;
    final card = flow.getCard();
    final cardMsg = card.name +
        '\r\n' +
        'Ходит ' +
        flow.currentUser.nickname +
        '(' +
        flow.currentUser.fullName +
        ')';
    unawaited(sendImage(game.id, card.imgUrl, cardMsg, false));
    unawaited(copyChat((chatId, _) {
      if (flow.currentUser.chatId == chatId) return;
      sendImage(chatId, card.imgUrl, cardMsg, false);
    }, game));

    unawaited(sendImage(flow.currentUser.chatId, card.imgUrl, card.name, false)
        .then((_) {
      sendEndTurn(flow);
    }));
  }

  Future showTrainingEndMessage(LitGame game, TelegramEx tele) async {
    telegram = tele;
    const litMsg = 'Разминку закончили, все молодцы!\r\n'
        'Сейчас таки начнём играть :-)';
    await telegram.sendMessage(game.id, litMsg);
    return copyChat((chatId, _) {
      telegram.sendMessage(chatId, litMsg);
    }, game);
  }
}
