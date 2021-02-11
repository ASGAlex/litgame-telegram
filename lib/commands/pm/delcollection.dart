// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class DelCollectionCmd extends ComplexCommand with AskAccess {
  @override
  String get name => 'delcollection';

  @override
  Map<String, CmdAction> get actionMap => {
        'ask-access': onAskAccess,
        'cancel-access': onCancelAccess,
        'allow-access': onAllowAccess,
        'deny-access': onDenyAccess,
        'delete': onDeleteCollection
      };

  @override
  ArgParser getParser() => super.getParser()..addOption('col');

  @protected
  get askAccessTextAdmin => 'хочет удалить набор карт';

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
            text = 'Админ разрешил вам удалить набор карт!';
          } else {
            text = 'Вам отказали в доступе на удаление набора карт.';
          }
          telegram.sendMessage(userId, text).then((value) {
            if (allow) {
              _askCollectionDelete(message, telegram, userId);
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

  void _askCollectionDelete(
      Message message, TelegramEx telegram, String userId) async {
    final collections = await CardCollection.listCollections();
    var buttons = <List<InlineKeyboardButton>>[];
    for (var col in collections) {
      final collection = col as CardCollection;
      buttons.add([
        InlineKeyboardButton(
            text: collection.name,
            callback_data: buildAction('delete', {'col': collection.objectId}))
      ]);
    }
    unawaited(telegram
        .sendMessage(userId, 'Выбирай, какую коллекцию удалить?',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: buttons))
        .then((value) {
      scheduleMessageDelete(value.chat.id, value.message_id);
    }));
  }

  @override
  void onNoAction(Message message, TelegramEx telegram) {
    super.onNoAction(message, telegram);
    user.registrationChecked.then((value) {
      if (accessAllowed) {
        _askCollectionDelete(message, telegram, message.from.id.toString());
      }
    });
  }

  // TODO: check if collection is playing now
  void onDeleteCollection(Message message, TelegramEx telegram) {
    final objId = arguments?['col'];
    if (objId == null) {
      throw 'Collection id not specified';
    }
    CardCollection.clone().getObject(objId).then((response) {
      if (!response.success) {
        throw 'Collection with id $objId not found';
      }
      final collection = response.results.first as CardCollection;
      collection.deleteWithCards().then((value) {
        telegram.sendMessage(
            message.chat.id, 'Коллекция ${collection.name} удалена.');
      });
    });
  }
}
