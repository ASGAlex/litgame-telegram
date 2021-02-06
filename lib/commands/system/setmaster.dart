// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/system/setorder.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:teledart_app/teledart_app.dart';

class SetMasterCmd extends Command {
  SetMasterCmd();

  @override
  ArgParser getParser() => getGameBaseParser()..addOption('userId');

  @override
  String get name => 'setmaster';

  @override
  void run(Message message, TelegramEx telegram) {
    deleteScheduledMessages(telegram);
    final player = game.players[int.parse(arguments?['userId'])];
    player?.isGameMaster = true;
    if (player != null) {
      telegram.sendMessage(
          gameChatId, player.nickname + '(' + player.fullName + ') будет игромастером!');

      final cmd = Command.withArguments(() => SetOrderCmd(),
          {'gci': gameChatId.toString(), 'userId': arguments?['userId'], 'reset': ''});
      cmd.run(message, telegram);
    }
  }
}
