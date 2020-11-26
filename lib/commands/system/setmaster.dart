import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/commands/system/setorder.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class SetMasterCmd extends Command {
  @override
  ArgParser getParser() {
    var parser = getBaseParser();
    parser.addOption('userId');
    return parser;
  }

  @override
  // TODO: implement name
  String get name => 'setmaster';

  @override
  void run(Message message, Telegram telegram) {
    cleanScheduledMessages(telegram);
    final player = game.players[int.parse(arguments?['userId'])];
    player?.isGameMaster = true;
    if (player != null) {
      telegram.sendMessage(
          gameChatId, player.nickname + '(' + player.fullName + ') будет игромастером!');
      telegram
          .sendMessage(message.chat.id, 'В каком порядке будут ходить игроки?',
              reply_markup:
                  InlineKeyboardMarkup(inline_keyboard: SetOrderCmd.getSortButtons(game)))
          .then((msg) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      });
    }
  }
}
