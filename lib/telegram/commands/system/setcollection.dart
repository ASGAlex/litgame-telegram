// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class SetCollectionCmd extends ComplexGameCommand {
  SetCollectionCmd();

  @override
  Map<String, CmdAction> get actionMap =>
      {'list': onCollectionList, 'select': onCollectionSelect};

  @override
  ArgParser getParser() =>
      super.getParser()..addOption('gci')..addOption('cid');

  @override
  bool get system => true;

  @override
  String get name => 'scl';

  void onCollectionSelect(Message message, TelegramEx telegram) {
    final collectionName = arguments?['cid'];
    _startGameWithCollection(collectionName);
  }

  void onCollectionList(Message message, TelegramEx telegram) {
    CardCollection.listCollections().then((collections) {
      final game = findGameByArguments();
      if (collections.isEmpty) {
        _resumeGameWithError(message, telegram, game);
        return;
      }

      if (collections.length == 1) {
        _startGameWithCollection(collections.first.name);
        return;
      }

      var collectionButtons = <List<InlineKeyboardButton>>[];
      collections.forEach((element) {
        collectionButtons.add([
          InlineKeyboardButton(
              text: element.name,
              callback_data: buildAction('select', {'cid': element.objectId}))
        ]);
      });

      telegram.sendMessage(game.master.chatId, 'Выбери коллекцию карт для игры',
          reply_markup:
              InlineKeyboardMarkup(inline_keyboard: collectionButtons));
    });
  }

  void _resumeGameWithError(
      Message message, TelegramEx telegram, LitGame game) {
    telegram
        .sendMessage(game.id,
            'Не нашлось ни одной колоды карт, а без них сыграть не выйдет..')
        .then((value) {
      final cmd = EndGameCmd();
      cmd.arguments = arguments;
      message.chat.id = game.id;
      message.from.id = game.admin.chatId;
      cmd.run(message, telegram);
    });
  }

  void _startGameWithCollection(String id) {
    final game = findGameByArguments();
    game.logic.add(SetupFinishedEvent(LitUser(message.from).fromGame(game)));
    final cmd = ComplexCommand.withAction(() => TrainingFlowCmd(), 'start',
        {'gci': arguments?['gci'], 'cid': id});
    cmd.run(message, telegram);
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    // TODO: implement onNoAction
  }
}
