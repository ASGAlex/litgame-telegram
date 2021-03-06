part of commands;

typedef MessageSender = void Function(int chatId, Completer completer);

mixin CopyChat on GameCmdMix {
  Future copyChat(MessageSender messageSender, LitGame game) {
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
