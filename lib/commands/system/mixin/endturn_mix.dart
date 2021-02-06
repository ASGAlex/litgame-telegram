// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:litgame_telegram/models/game/flow_interface.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

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
