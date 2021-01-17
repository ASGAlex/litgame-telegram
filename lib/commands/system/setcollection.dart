// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';
import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/commands/endgame.dart';
import 'package:litgame_telegram/commands/system/trainingflow.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

class SetCollectionCmd extends ComplexCommand {
  SetCollectionCmd();

  @override
  Map<String, CmdAction> get actionMap =>
      {'list': onCollectionList, 'select': onCollectionSelect};

  @override
  ArgParser getParser() => super.getParser()..addOption('gci')..addOption('cid');

  SetCollectionCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  bool get system => true;

  @override
  String get name => 'scl';

  void onCollectionSelect(Message message, LitTelegram telegram) {
    final collectionName = arguments?['cid'];
    _startGameWithCollection(collectionName);
  }

  void onCollectionList(Message message, LitTelegram telegram) {
    CardCollection.listCollections().then((collections) {
      if (collections.isEmpty) {
        _resumeGameWithError(message, telegram);
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
          reply_markup: InlineKeyboardMarkup(inline_keyboard: collectionButtons));
    });
  }

  void _resumeGameWithError(Message message, LitTelegram telegram) {
    telegram
        .sendMessage(
            gameChatId, 'Не нашлось ни одной колоды карт, а без них сыграть не выйдет..')
        .then((value) {
      final cmd = EndGameCmd();
      cmd.arguments = arguments;
      message.chat.id = gameChatId;
      message.from.id = game.admin.chatId;
      cmd.run(message, telegram);
    });
  }

  void _startGameWithCollection(String id) {
    final cmd = ComplexCommand.withAction(
        () => TrainingFlowCmd(), 'start', {'gci': arguments?['gci'], 'cid': id});
    cmd.run(message, telegram);
  }

  @override
  void onNoAction(Message message, LitTelegram telegram) {
    // TODO: implement onNoAction
  }

  @override
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    parameters['gci'] = gameChatId.toString();
    return super.buildAction(actionName, parameters);
  }
}
