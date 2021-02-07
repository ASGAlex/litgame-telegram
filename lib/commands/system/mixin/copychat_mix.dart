import 'dart:async';

import 'package:litgame_telegram/commands/game_command.dart';

typedef MessageSender = void Function(int chatId, Completer completer);

mixin CopyChat on GameCmdMix {
  Future copyChat(MessageSender messageSender) {
    final completer = Completer();
    var found = false;
    for (var player in game.players.entries) {
      final litUser = player.value;
      if (litUser.isCopyChatSet) {
        found = true;
        messageSender(litUser.chatId, completer);
      }
    }

    if (!found) {
      completer.complete();
    }
    return completer.future;
  }
}
