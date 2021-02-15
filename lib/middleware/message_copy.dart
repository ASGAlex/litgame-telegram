import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart_app/teledart_app.dart';

class MessageCopy with Middleware {
  @override
  void handle(Update data, TelegramEx telegram) {
    if (isCmd) return;
    if (isCallbackQuery) return;
    if (data.message == null) return;

    if (data.message?.chat.type == 'private') {
      final user = LitUser(data.message.from);
      user.registrationChecked.then((registered) {
        _copyPMMessagesToGameChat(data.message, telegram);
      });
    } else {
      _copyGameChatMessagesToPM(data.message, telegram);
    }
  }

  void _copyPMMessagesToGameChat(Message message, TelegramEx telegram) {
    final player = LitGame.findPlayerInExistingGames(message.chat.id);
    if (player != null && player.isCopyChatSet) {
      final gameChatId = player.currentGame?.chatId;
      if (gameChatId == null) {
        throw 'Player is in game, but currentGame.chatId is null!';
      }
      telegram.forwardMessage(gameChatId, message.chat.id, message.message_id);
    }
  }

  void _copyGameChatMessagesToPM(Message message, TelegramEx telegram) {
    final game = LitGame.find(message.chat.id);
    if (game == null) return;
    if (!game.players.containsKey(message.from.id)) return;
    for (var player in game.players.entries) {
      if (player.value.telegramUser.id == message.from.id) continue;
      if (!player.value.isCopyChatSet) continue;

      telegram.forwardMessage(
          player.value.chatId, message.chat.id, message.message_id);
    }
  }
}
