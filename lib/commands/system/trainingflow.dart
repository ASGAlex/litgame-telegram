import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
import 'package:litgame_telegram/commands/system/gameflow.dart';
import 'package:litgame_telegram/commands/system/mixin/endturn_mix.dart';
import 'package:litgame_telegram/commands/system/mixin/image_mix.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/game_flow.dart';
import 'package:litgame_telegram/models/game/traning_flow.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:pedantic/pedantic.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import '../complex_command.dart';

class TrainingFlowCmd extends ComplexCommand with ImageSender, EndTurn {
  TrainingFlowCmd();

  TrainingFlowCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  ArgParser getParser() => super.getParser()..addOption('gci')..addOption('cid');

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
  void run(Message message, LitTelegram telegram) async {
    cleanScheduledMessages(telegram);
    var collectionName = 'default';
    var collectionId = arguments?['cid'];
    if (collectionId != null) {
      await CardCollection.getName(collectionId).then((value) {
        collectionName = value.name;
      });
    }
    gameFlow = GameFlow.init(game, collectionName);
    if (gameFlow.turnNumber > 0) {
      unawaited(telegram.sendMessage(
          game.master.chatId, 'Какая разминка, игра уже в разгаре!'));
      return;
    }
    trainingFlow = TrainingFlow.init(gameFlow);
    await gameFlow.init;
    super.run(message, telegram);
  }

  @override
  void onNoAction(Message message, LitTelegram telegram) {
    // TODO: implement onNoAction
  }

  void onTrainingStart(Message message, LitTelegram telegram) {
    telegram.sendMessage(
        game.chatId,
        'Небольшая разминка!\r\n'
        'Сейчас каждому из игроков будет выдаваться случайная карта из колоды,'
        'и нужно будет по ней рассказать что-то, что связано с миром/темой, '
        'на которую вы собираетесь играть.\r\n'
        'Это позволит немного разогреть мозги, вспомнить забытые факты и "прокачать"'
        'менее подготовленных к игре товарищей.\r\n');
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
  }

  void onNextTurn(Message message, LitTelegram telegram) {
    if (!firstStep) {
      trainingFlow.nextTurn();
    }
    final card = trainingFlow.getCard();
    sendImage(
        game.chatId,
        card.imgUrl,
        card.name +
            '\r\n' +
            'Ходит ' +
            trainingFlow.currentUser.nickname +
            '(' +
            trainingFlow.currentUser.fullName +
            ')');
    sendImage(trainingFlow.currentUser.chatId, card.imgUrl, card.name).then((value) {
      sendEndTurn(trainingFlow);
    });
  }

  void onTrainingEnd(Message message, LitTelegram telegram) {
    telegram.sendMessage(
        game.chatId,
        'Разминку закончили, все молодцы!\r\n'
        'Сейчас таки начнём играть :-)');

    TrainingFlow.stopGame(game.chatId);
    gameFlow.turnNumber = 1;
    final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'start',
        {'gci': game.chatId.toString(), 'cid': gameFlow.collectionId});
    cmd.run(message, telegram);
  }

  @override
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    parameters['gci'] = gameChatId.toString();
    return super.buildAction(actionName, parameters);
  }
}
