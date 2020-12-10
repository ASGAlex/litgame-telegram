import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/commands/system/setorder.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

import '../../telegram.dart';

class SetMasterCmd extends Command {
  SetMasterCmd();

  SetMasterCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  ArgParser getParser() => getGameBaseParser()..addOption('userId');

  @override
  String get name => 'setmaster';

  @override
  void run(Message message, LitTelegram telegram) {
    cleanScheduledMessages(telegram);
    final player = game.players[int.parse(arguments?['userId'])];
    player?.isGameMaster = true;
    if (player != null) {
      telegram.sendMessage(
          gameChatId, player.nickname + '(' + player.fullName + ') будет игромастером!');

      final cmd = Command.withArguments(
          () => SetOrderCmd(), {'gci': gameChatId.toString(), 'reset': ''});
      cmd.run(message, telegram);
    }
  }
}
