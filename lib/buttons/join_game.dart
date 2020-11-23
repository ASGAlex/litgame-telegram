import 'package:litgame_telegram/buttons/core.dart';
import 'package:litgame_telegram/commands/startgame.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart/src/telegram/telegram.dart';

class JoinGame extends ButtonCallback {
  JoinGame(int messageId) : super(messageId);

  @override
  void run(Message message, Telegram telegram) {
    final user = LitUser(message.from);
    final game = LitGame.find(message.chat.id);
    bool sendReport = false;
    if (message.text == StartGameCmd.BTN_YES) {
      sendReport = game.addPlayer(user);
      if (user.chatId == null) {
        _sendChatIdRequest(message, user, telegram);
      }
    } else if (message.text == StartGameCmd.BTN_NO) {
      game.removePlayer(user);
      sendReport = true;
    }

    if (true) {
      _sendStatisticsToAdmin(game, telegram);
    }
  }

  void _sendChatIdRequest(Message message, LitUser user, Telegram telegram) {
    user.awaitChatId();
    telegram.sendMessage(
        message.chat.id,
        user.getNickname() +
            " напиши мне в личку что-нибудь, чтобы я мог слать тебе уведомления о событиях в игре");
  }

  void _sendStatisticsToAdmin(LitGame game, Telegram telegram) {
    if (game.admin.chatId == null) return;
    String text = "*В игре примут участие:*\r\n";
    for (LitUser user in game.players.values) {
      text += " - " +
          user.getNickname() +
          " (" +
          user.telegramUser.first_name +
          (user.telegramUser.last_name ?? "") +
          ")\r\n";
    }
    if (game.players.isEmpty) {
      text = "*что-то все расхотели играть*";
    }

    text = text.replaceAll('-', '\\-').replaceAll('(', '\\(').replaceAll(')', '\\)');
    telegram.sendMessage(game.admin.chatId, text, parse_mode: 'MarkdownV2');
  }
}
