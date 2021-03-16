part of commands;

mixin AskAccess on ComplexCommand {
  late LitUser user;
  bool accessAllowed = false;

  @override
  Map<String, CmdAction> get actionMap => {
        'ask-access': onAskAccess,
        'cancel-access': onCancelAccess,
        'allow-access': onAllowAccess,
        'deny-access': onDenyAccess
      };

  @protected
  String get askAccessTextAdmin => 'хочет залить новый набор карт';

  String get askAccessTextUser =>
      'Чтобы продолжить, нужно запросить у админа разрешение. Продолжить?';

  @override
  bool get system => false;

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

  @override
  ArgParser getParser() => super.getParser()..addOption('userId');

  void onAskAccess(Message message, TelegramEx telegram) {
    LitUser.adminUsers.forEach((int chatId) {
      telegram
          .sendMessage(
              chatId,
              'Пользователь ' +
                  user.nickname +
                  '(' +
                  user.fullName +
                  ') ' +
                  askAccessTextAdmin,
              reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                [
                  InlineKeyboardButton(
                      text: 'Разрешить',
                      callback_data: buildAction('allow-access',
                          {'userId': user.telegramUser.id.toString()})),
                  InlineKeyboardButton(
                      text: 'Отказать',
                      callback_data: buildAction('deny-access',
                          {'userId': user.telegramUser.id.toString()}))
                ]
              ]))
          .then((value) {
        scheduleMessageDelete(chatId, value.message_id);
      });
    });
  }

  void onCancelAccess(Message message, TelegramEx telegram) {
    telegram.sendMessage(
        message.chat.id, 'Спасибо, что не беспокоите админа просто так :-)');
  }

  @override
  @mustCallSuper
  void onNoAction(Message message, TelegramEx telegram) {
    user.registrationChecked.then((value) {
      if (!user.isAllowedAddCollection &&
          !LitUser.adminUsers.contains(user.chatId)) {
        accessAllowed = false;
        telegram
            .sendMessage(message.chat.id, askAccessTextUser,
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
        accessAllowed = true;
      }
    });
  }

  void onAllowAccess(Message message, TelegramEx telegram);

  void onDenyAccess(Message message, TelegramEx telegram);
}
