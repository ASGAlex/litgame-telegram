// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:meta/meta.dart';
import 'package:teledart_app/teledart_app.dart';

mixin GameCmdMix on Command {
  ArgParser getGameBaseParser() {
    var parser = ArgParser();
    parser.addOption('gci');
    return parser;
  }

  LitGame get game {
    var gameChatId = arguments?['gci'];
    if (arguments?['gci'] is String) {
      gameChatId = int.parse(arguments?['gci']);
    }
    var game = LitGame.find(gameChatId);
    if (game == null) throw 'В этом чате не играется ни одна игра';
    return game;
  }

  int? get gameChatId =>
      (arguments?['gci'] is String) ? int.parse(arguments?['gci']) : arguments?['gci'];

  @protected
  void checkGameChat(Message message) {
    if (message.chat.id > 0) {
      throw 'Эту команду надо не в личке запускать, а в чате с игроками ;-)';
    }
  }
}

abstract class GameCommand extends Command with GameCmdMix implements GameCmdMix {}

abstract class ComplexGameCommand extends ComplexCommand
    with GameCmdMix
    implements GameCmdMix {}
