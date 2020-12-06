import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/commands/system/finishjoin.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import '../../telegram.dart';

class JoinMeCmd extends Command {
  JoinMeCmd();

  JoinMeCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  String get name => 'joinme';

  @override
  void run(Message message, LitTelegram telegram) {
    final user = LitUser(message.from);
    final _game = LitGame.find(message.chat.id);
    if (_game == null) {
      throw 'В этом чате нет запущенных игр';
    }
    var sendReport = _game.addPlayer(user);
    _sendChatIdRequest(message, user, telegram);

    if (sendReport) {
      sendStatisticsToAdmin(_game, telegram, message.chat.id);
    }
  }

  void _sendChatIdRequest(Message message, LitUser user, LitTelegram telegram) {
    var text = user.nickname + ' подключился к игре!\r\n';
    user.registrationChecked.then((registered) {
      if (!registered) {
        text +=
            'Мы с тобой ещё не общались, напиши мне в личку, чтобы продолжить игру.\r\n';
      }
      telegram.sendMessage(message.chat.id, text);
    });
  }

  @protected
  void sendStatisticsToAdmin(LitGame game, LitTelegram telegram, int gameChatId) {
    if (game.admin.noChatId) return;
    var text = '*В игре примут участие:*\r\n';
    late ReplyMarkup markup;
    for (var user in game.players.values) {
      text += ' - ' + user.nickname + ' (' + user.fullName + ')\r\n';
    }
    if (game.players.isEmpty) {
      text = '*что-то все расхотели играть*';
      markup = ReplyMarkup();
    } else {
      markup = InlineKeyboardMarkup(inline_keyboard: [
        [
          InlineKeyboardButton(
              text: 'Завершить набор игроков',
              callback_data: FinishJoinCmd.args(arguments)
                  .buildCommandCall({'gci': gameChatId.toString()}))
        ]
      ]);
    }

    text = text.replaceAll('-', '\\-').replaceAll('(', '\\(').replaceAll(')', '\\)');
    telegram
        .sendMessage(game.admin.chatId, text,
            parse_mode: 'MarkdownV2', reply_markup: markup)
        .then((message) {
      scheduleMessageDelete(message.chat.id, message.message_id);
    });
  }

  @override
  ArgParser? getParser() => null;
}
