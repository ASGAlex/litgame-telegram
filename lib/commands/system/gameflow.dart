// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
import 'package:litgame_telegram/commands/system/mixin/copychat_mix.dart';
import 'package:litgame_telegram/commands/system/mixin/endturn_mix.dart';
import 'package:litgame_telegram/commands/system/mixin/image_mix.dart';
import 'package:litgame_telegram/models/cards/card.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/game_flow.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

import '../../telegram.dart';
import '../complex_command.dart';

class GameFlowCmd extends ComplexCommand with ImageSender, EndTurn, CopyChat {
  GameFlowCmd();

  GameFlowCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  ArgParser getParser() => super.getParser()..addOption('gci')..addOption('cid');

  late GameFlow flow;

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
  void run(Message message, LitTelegram telegram) {
    this.message = message;
    this.telegram = telegram;
    var collectionName = 'default';
    if (arguments?['action'] == 'start') {
      var collectionId = arguments?['cid'];
      CardCollection.getName(collectionId).then((value) {
        collectionName = value.name;
        _gameFlowInitAndRun(collectionName);
      });
    } else {
      _gameFlowInitAndRun(collectionName);
    }
  }

  void _gameFlowInitAndRun(String collectionName) {
    flow = GameFlow.init(game, collectionName);

    if (message.chat.id != flow.currentUser.chatId) {
      telegram.sendMessage(message.chat.id, 'Сейчас не твой ход!').then((value) {
        scheduleMessageDelete(value.chat.id, value.message_id);
      });
    }

    flow.init.then((value) {
      super.run(message, telegram);
    });
  }

  void onGameStart(Message message, Telegram telegram) {
    if (flow.currentUser.isGameMaster && flow.turnNumber == 1) {
      telegram.sendMessage(flow.game.chatId,
          'Ходит ' + flow.currentUser.nickname + '(' + flow.currentUser.fullName + ')');

      copyChat((chatId, _) {
        if (flow.currentUser.chatId == chatId) return;
        telegram.sendMessage(chatId,
            'Ходит ' + flow.currentUser.nickname + '(' + flow.currentUser.fullName + ')');
      });

      var cGeneric = flow.getCard(CardType.generic);
      var cPlace = flow.getCard(CardType.place);
      var cPerson = flow.getCard(CardType.person);
      sendImage(flow.currentUser.chatId, cGeneric.imgUrl, cGeneric.name, false)
          .then((value) {
        sendImage(flow.currentUser.chatId, cPlace.imgUrl, cPlace.name, false)
            .then((value) {
          sendImage(flow.currentUser.chatId, cPerson.imgUrl, cPerson.name, false)
              .then((value) {
            sendEndTurn(flow);
          });
        });
      });

      sendImage(flow.game.chatId, cGeneric.imgUrl, cGeneric.name, false).then((value) {
        sendImage(flow.game.chatId, cPlace.imgUrl, cPlace.name, false).then((value) {
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

  void onNextTurn(Message message, LitTelegram telegram) {
    cleanScheduledMessages(telegram);
    flow.nextTurn();
    telegram.sendMessage(flow.game.chatId,
        'Ходит ' + flow.currentUser.nickname + '(' + flow.currentUser.fullName + ')');

    copyChat((chatId, _) {
      if (flow.currentUser.chatId == chatId) return;
      telegram.sendMessage(chatId,
          'Ходит ' + flow.currentUser.nickname + '(' + flow.currentUser.fullName + ')');
    });

    telegram
        .sendMessage(flow.currentUser.chatId, 'Тянем карту!',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: 'Общая', callback_data: buildAction('select-generic')),
                InlineKeyboardButton(
                    text: 'Место', callback_data: buildAction('select-place')),
                InlineKeyboardButton(
                    text: 'Персонаж', callback_data: buildAction('select-person')),
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  void onSelectCard(Message message, Telegram telegram) {
    cleanScheduledMessages(telegram);
    var sType = action.replaceAll('select-', '');
    var type = CardType.generic.getTypeByName(sType);
    var card = flow.getCard(type);
    sendImage(flow.currentUser.chatId, card.imgUrl, card.name, false).then((value) {
      sendEndTurn(flow);
    });
    sendImage(flow.game.chatId, card.imgUrl, card.name, false);
    copyChat((chatId, _) {
      if (flow.currentUser.chatId == chatId) return;
      sendImage(chatId, card.imgUrl, card.name, false);
    });
  }

  @override
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    parameters['gci'] = gameChatId.toString();
    return super.buildAction(actionName, parameters);
  }

  @override
  void onNoAction(Message message, Telegram telegram) {}
}
