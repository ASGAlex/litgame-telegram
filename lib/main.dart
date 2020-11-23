import 'package:litgame_telegram/commands/startgame.dart';
import 'package:litgame_telegram/router.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'commands/endgame.dart';

void main() {
  final telegram = Telegram('');
  final polling = LongPolling(telegram);
  Stream<Update> stream = polling.onUpdate();

  final router = Router(telegram);
  router.registerCommand(StartGameCmd());
  router.registerCommand(EndGameCmd());

  stream.listen((Update data) {
    try {
      router.dispatch(data);
    } catch (exception) {
      telegram.sendMessage(data.message.chat.id, exception.toString(),
          reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
    }
  });
  polling.start();
}
