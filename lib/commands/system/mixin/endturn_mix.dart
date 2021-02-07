// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

mixin EndTurn on ComplexCommand {
  @protected
  void sendEndTurn(FlowInterface flow) {
    telegram
        .sendMessage(flow.currentUser.chatId, 'Когда закончишь свою историю - жми:',
            reply_markup: InlineKeyboardMarkup(inline_keyboard: [
              [
                InlineKeyboardButton(
                    text: 'Завершить ход', callback_data: buildAction('next-turn'))
              ]
            ]))
        .then((msg) {
      scheduleMessageDelete(msg.chat.id, msg.message_id);
    });
  }
}
