import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
import 'package:litgame_telegram/models/cards/card.dart';
import 'package:litgame_telegram/models/game/game_flow.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

import '../../telegram.dart';
import '../complex_command.dart';

class GameFlowCmd extends ComplexCommand {
  GameFlowCmd();
  GameFlowCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  ArgParser getParser() {
    var parser = super.getParser();
    parser.addOption('gameChatId');
    return parser;
  }

  late Telegram telegram;
  late GameFlow flow;
  late Message message;

  @override
  String get name => 'gameflow';

  @override
  // TODO: implement actionMap
  Map<String, CmdAction> get actionMap => {
        'start': onGameStart,
        'select-generic': onSelectCard,
        'select-place': onSelectCard,
        'select-person': onSelectCard,
        'next-turn': onNextTurn,
      };

  @override
  void run(Message message, LitTelegram telegram) {
    this.message = message;
    this.telegram = telegram;
    flow = GameFlow.init(game);

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
      var cGeneric = flow.getCard(CardType.generic);
      var cPlace = flow.getCard(CardType.place);
      var cPerson = flow.getCard(CardType.person);
      _sendImage(flow.currentUser.chatId, cGeneric.imgUrl, cGeneric.name).then((value) {
        _sendImage(flow.currentUser.chatId, cPlace.imgUrl, cPlace.name).then((value) {
          _sendImage(flow.currentUser.chatId, cPerson.imgUrl, cPerson.name).then((value) {
            _sendEndTurn(flow);
          });
        });
      });

      _sendImage(flow.game.chatId, cGeneric.imgUrl, cGeneric.name, false).then((value) {
        _sendImage(flow.game.chatId, cPlace.imgUrl, cPlace.name, false).then((value) {
          _sendImage(flow.game.chatId, cPerson.imgUrl, cPerson.name, false);
        });
      });
    } else {
      throw 'Invalid game start process';
    }
  }

  void onNextTurn(Message message, Telegram telegram) {
    cleanScheduledMessages(telegram);
    flow.nextTurn();
    telegram
        .sendMessage(flow.game.chatId,
            'Ходит ' + flow.currentUser.nickname + '(' + flow.currentUser.fullName + ')')
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
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
    _sendImage(flow.currentUser.chatId, card.imgUrl, card.name).then((value) {
      _sendEndTurn(flow);
    });
    _sendImage(flow.game.chatId, card.imgUrl, card.name, false);
  }

  void _sendEndTurn(GameFlow flow) {
    telegram
        .sendMessage(flow.currentUser.chatId, 'Когда закончишь свою историю - жми:',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: 'Заввершить ход', callback_data: buildAction('next-turn'))
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }

  Future _sendImage(int chatId, String url, String caption, [bool clear = true]) {
    return telegram.sendPhoto(chatId, url, caption: caption).then((msg) {
      if (clear) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      }
    });
  }

  @override
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    parameters['gameChatId'] = gameChatId.toString();
    return super.buildAction(actionName, parameters);
  }

  @override
  void onNoAction(Message message, Telegram telegram) {}
}
