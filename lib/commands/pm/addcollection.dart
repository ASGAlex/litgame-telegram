import 'package:litgame_telegram/models/game/user.dart';
import 'package:litgame_telegram/router.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import '../../telegram.dart';
import '../complex_command.dart';

class AddCollectionCmd extends ComplexCommand {
  static final List<int> usersAwaitForUpload = [];

  @override
  Map<String, CmdAction> get actionMap => {
        'ask-access': onAskAccess,
        'cancel-access': onCancelAccess,
        'allow-access': onAllowAccess,
        'deny-access': onDenyAccess
      };

  late LitUser user;

  @override
  bool get system => false;

  @override
  String get name => 'addcollection';

  @override
  void run(Message message, LitTelegram telegram) {
    if (message.chat.type != 'private') {
      telegram.sendMessage(message.chat.id, 'Давай поговорим об этом в личке?');
      return;
    }

    user = LitUser(message.from);
    super.run(message, telegram);
  }

  void onAskAccess(Message message, LitTelegram telegram) {
    LitUser.adminUsers.forEach((int chatId) {
      telegram.sendMessage(
          chatId,
          'Пользователь ' +
              user.nickname +
              '(' +
              user.fullName +
              ') хочет залить новый набор карт',
          reply_markup: InlineKeyboardMarkup(inline_keyboard: [
            [
              InlineKeyboardButton(
                  text: 'Разрешить',
                  callback_data: buildAction(
                      'allow-access', {'userId': user.telegramUser.id.toString()})),
              InlineKeyboardButton(
                  text: 'Разрешить',
                  callback_data: buildAction(
                      'deny-access', {'userId': user.telegramUser.id.toString()}))
            ]
          ]));
    });
  }

  void onAllowAccess(Message message, LitTelegram telegram) {
    _accessAllowDeny(true, message, telegram);
  }

  void onDenyAccess(Message message, LitTelegram telegram) {
    _accessAllowDeny(false, message, telegram);
  }

  void _accessAllowDeny(bool allow, Message message, LitTelegram telegram) {
    var userId = arguments?['userId'];
    if (userId == null) return;

    final user = LitUser.clone(userId);
    user.allowAddCollection(allow).then((ParseResponse response) {
      if (response.success) {
        late var text;
        if (allow) {
          text = 'Админ разрешил вам загружать новые наборы карт!';
        } else {
          text = 'Вам отказали в доступе на загрузку наборов карт.';
        }
        telegram.sendMessage(userId, text).then((value) {
          if (allow) {
            _askArchUpload(message, telegram);
          }
        });
      }
    });
  }

  void onCancelAccess(Message message, LitTelegram telegram) {
    telegram.sendMessage(
        message.chat.id, 'Спасибо, что не беспокоите админа просто так :-)');
  }

  @override
  void onNoAction(Message message, LitTelegram telegram) {
    if (!user.isAllowedAddCollection && !LitUser.adminUsers.contains(user.chatId)) {
      telegram.sendMessage(message.chat.id,
          'Чтобы продолжить, нужно запросить у админа разрешение на загрзку. Продолжить?',
          reply_markup: InlineKeyboardMarkup(inline_keyboard: [
            [
              InlineKeyboardButton(text: 'Да', callback_data: buildAction('ask-access')),
              InlineKeyboardButton(
                  text: 'Нет, я ещё подумаю...',
                  callback_data: buildAction('cancel-access')),
            ]
          ]));
      return;
    }

    if (usersAwaitForUpload.contains(message.chat.id)) {
    } else {
      _askArchUpload(message, telegram);
    }
  }

  void _askArchUpload(Message message, LitTelegram telegram) {
    telegram.sendMessage(message.chat.id, 'Загрузи в чат архив с новой коллекцией');
    usersAwaitForUpload.add(message.chat.id);
    RouterController().willProcessNextMessageInChat(message.chat.id, this);
  }
}
