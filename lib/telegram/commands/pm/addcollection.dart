// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class AddCollectionCmd extends ComplexCommand with AskAccess {
  static final List<int> usersAwaitForUpload = [];

  @override
  Map<String, CmdAction> get actionMap => {
        'ask-access': onAskAccess,
        'cancel-access': onCancelAccess,
        'allow-access': onAllowAccess,
        'deny-access': onDenyAccess
      };

  @override
  String get name => 'addcollection';

  @override
  void onAllowAccess(Message message, TelegramEx telegram) {
    _accessAllowDeny(true, message, telegram);
  }

  @override
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

  @override
  // ignore: must_call_super
  void onNoAction(Message message, TelegramEx telegram) {
    user.registrationChecked.then((value) {
      if (usersAwaitForUpload.contains(message.chat.id) &&
          message.document != null) {
        telegram.getFile(message.document.file_id).then((file) {
          final url = file.getDownloadLink(telegram.token);
          final collection = CardCollection.fromArchive(url);
          telegram.sendMessage(message.chat.id, 'Обрабатываем коллекцию...');
          collection.loaded?.then((value) {
            telegram.sendMessage(message.chat.id,
                'Отлично, новая коллекция "${collection.name}" загружена!');
          });
        });
        return;
      }
      if (!user.isAllowedAddCollection &&
          !LitUser.adminUsers.contains(user.chatId)) {
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
