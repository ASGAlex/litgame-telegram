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
    super.run(message, telegram);
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    // TODO: implement onNoAction
  }

  void onTrainingStart(Message message, TelegramEx telegram) {
    game.logic.addEvent(
        GameEventType.trainingStart, LitUser(message.from), arguments?['cid']);
  }

  void onNextTurn(Message message, TelegramEx telegram) {
    game.logic.addEvent(GameEventType.trainingNextTurn, LitUser(message.from));
  }

  void onTrainingEnd(Message message, TelegramEx telegram) {
    game.logic.addEvent(GameEventType.trainingEnd, LitUser(message.from));
  }

  void sendNextTurnToChat(LitGame game, TelegramEx tele) async {
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
    }));

    unawaited(sendImage(flow.currentUser.chatId, card.imgUrl, card.name, false)
        .then((value) {
      sendEndTurn(flow);
    }));
  }

  Future sendTrainingEndToChat(LitGame game, TelegramEx tele) async {
    telegram = tele;
    const litMsg = 'Разминку закончили, все молодцы!\r\n'
        'Сейчас таки начнём играть :-)';
    await telegram.sendMessage(game.id, litMsg);
    return copyChat((chatId, _) {
      telegram.sendMessage(chatId, litMsg);
    });
  }
}
