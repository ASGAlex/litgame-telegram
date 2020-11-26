import 'dart:io';

import 'package:args/args.dart';
import 'package:litgame_telegram/commands/finishjoin.dart';
import 'package:litgame_telegram/commands/joinme.dart';
import 'package:litgame_telegram/commands/kickme.dart';
import 'package:litgame_telegram/commands/setmaster.dart';
import 'package:litgame_telegram/commands/startgame.dart';
import 'package:litgame_telegram/router.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'commands/endgame.dart';

Future main(List<String> arguments) async {
  final parser = ArgParser();
  String botKey;
  parser.addOption('botKey', abbr: 'k');
  try {
    final results = parser.parse(arguments);
    botKey = results['botKey'];
  } on ArgumentError catch (error) {
    print('--botKey option must be specified!');
    exit(1);
  } on ArgParserException catch (error) {
    print('--botKey option must be specified!');
    exit(1);
  }
  // await LitUser.loadChatIdStorage();

  final telegram = Telegram(botKey);
  final polling = LongPolling(telegram);
  Stream<Update> stream = polling.onUpdate();

  final router = Router(telegram);
  router.registerCommand(StartGameCmd());
  router.registerCommand(EndGameCmd());
  router.registerCommand(JoinMeCmd());
  router.registerCommand(KickMeCmd());
  router.registerCommand(FinishJoinCmd());
  router.registerCommand(SetMasterCmd());

  stream.listen((Update data) {
    try {
      router.dispatch(data);
    } catch (exception) {
      var chatId = data.message?.chat.id ?? data.callback_query?.message.chat.id;
      telegram.sendMessage(chatId, exception.toString());
    }
  });
  polling.start();
}
