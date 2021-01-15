import 'package:litgame_telegram/commands/core_command.dart';

typedef MessageSender = void Function(int chatId);

mixin CopyChat on Command {
  void copyChat(MessageSender messageSender) {
    game.players.forEach((key, litUser) {
      if (litUser.isCopyChatSet) {
        messageSender(litUser.chatId);
      }
    });
  }
}
