// ignore_for_file: import_of_legacy_library_into_null_safe

part of commands;

class EndGameCmd extends GameCommand {
  EndGameCmd();
  @override
  String get name => 'endgame';

  @override
  bool get system => false;

  @override
  void run(Message message, TelegramEx telegram) {
    initTeledart(message, telegram);
    checkGameChat(message);
    initGameLogic(StopGame(message.chat.id, LitUser(message.from)));

    // var game = LitGame.find(message.chat.id);
    // var userId = message.from.id;
    // if (game != null) {
    //   const errorMessage =
    //       'У тебя нет власти надо мной! Пусть админ игры её остановит.';
    //   var player = game.players[userId];
    //   if (player == null) {
    //     throw errorMessage;
    //   }
    //   if (!player.isAdmin) {
    //     throw errorMessage;
    //   }
    // }
    // LitGame.stopGame(message.chat.id);
    // GameFlow.stopGame(message.chat.id);
    // TrainingFlow.stopGame(message.chat.id);
  }

  @override
  ArgParser? getParser() => null;

  @override
  void stateLogic(GameState state) {
    if (state is NoGame) {
      telegram.sendMessage(message.chat.id, 'Всё, наигрались!',
          reply_markup: ReplyKeyboardRemove(remove_keyboard: true));
      deleteScheduledMessages(telegram);
    } else {}
  }
}
