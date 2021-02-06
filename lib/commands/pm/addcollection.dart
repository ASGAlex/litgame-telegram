// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart_app/teledart_app.dart';

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
  ArgParser getParser() => super.getParser()..addOption('userId');

  @override
  void run(Message message, TelegramEx telegram) {
    if (message.chat.type != 'private') {
      telegram.sendMessage(message.chat.id, 'Давай поговорим об этом в личке?');
      return;
    }

    user = LitUser(message.from);
    deleteScheduledMessages(telegram);
    super.run(message, telegram);
  }

  void onAskAccess(Message message, TelegramEx telegram) {
    LitUser.adminUsers.forEach((int chatId) {
      telegram
          .sendMessage(
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
                      text: 'Отказать',
                      callback_data: buildAction(
                          'deny-access', {'userId': user.telegramUser.id.toString()}))
                ]
              ]))
          .then((value) {
        scheduleMessageDelete(chatId, value.message_id);
      });
    });
  }

  void onAllowAccess(Message message, TelegramEx telegram) {
    _accessAllowDeny(true, message, telegram);
  }

  void onDenyAccess(Message message, TelegramEx telegram) {
    _accessAllowDeny(false, message, telegram);
  }

  void _accessAllowDeny(bool allow, Message message, TelegramEx telegram) {
    var userId = arguments?['userId'];
    if (userId == null) return;

    final processedUser = LitUser.byId(int.parse(userId));

    processedUser.registrationChecked.then((value) {
      processedUser.allowAddCollection(allow).then((ParseResponse response) {
        if (response.success) {
          late var text;
          if (allow) {
            text = 'Админ разрешил вам загружать новые наборы карт!';
          } else {
            text = 'Вам отказали в доступе на загрузку наборов карт.';
          }
          telegram.sendMessage(userId, text).then((value) {
            if (allow) {
              _askArchUpload(message, telegram, int.parse(userId));
            }
          });
        }
      });
    });
  }

  void onCancelAccess(Message message, TelegramEx telegram) {
    telegram.sendMessage(
        message.chat.id, 'Спасибо, что не беспокоите админа просто так :-)');
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    user.registrationChecked.then((value) {
      if (usersAwaitForUpload.contains(message.chat.id) && message.document != null) {
        telegram.getFile(message.document.file_id).then((file) {
          final url =
              'https://api.telegram.org/file/bot${telegram.token}/${file.file_path}';
          final collection = CardCollection.fromArchive(url);
          telegram.sendMessage(message.chat.id, 'Обрабатываем коллекцию...');
          collection.loaded?.then((value) {
            telegram.sendMessage(message.chat.id,
                'Отлично, новая коллекция "${collection.name}" загружена!');
          });
        });
        return;
      }
      if (!user.isAllowedAddCollection && !LitUser.adminUsers.contains(user.chatId)) {
        telegram
            .sendMessage(message.chat.id,
                'Чтобы продолжить, нужно запросить у админа разрешение на загрзку. Продолжить?',
                reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                  [
                    InlineKeyboardButton(
                        text: 'Да', callback_data: buildAction('ask-access')),
                    InlineKeyboardButton(
                        text: 'Нет, я ещё подумаю...',
                        callback_data: buildAction('cancel-access')),
                  ]
                ]))
            .then((value) {
          scheduleMessageDelete(message.chat.id, value.message_id);
        });
      } else {
        _askArchUpload(message, telegram, message.chat.id);
      }
    });
  }

  void _askArchUpload(Message message, TelegramEx telegram, int userId) {
    telegram.sendMessage(userId, 'Загрузи в чат архив с новой коллекцией');
    usersAwaitForUpload.add(userId);
    reset();
    callMeOnNextMessage(userId);
  }
}
