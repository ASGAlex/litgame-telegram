import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/models/game/flow_interface.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';

mixin EndTurn on ComplexCommand {
  @protected
  void sendEndTurn(FlowInterface flow) {
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
}
