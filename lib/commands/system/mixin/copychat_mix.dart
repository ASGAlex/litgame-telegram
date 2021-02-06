import 'dart:async';

import 'package:teledart_app/teledart_app.dart';

typedef MessageSender = void Function(int chatId, Completer completer);

mixin CopyChat on Command {
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
