import 'dart:io';

import 'package:args/args.dart';
import 'package:litgame_telegram/commands/startgame.dart';
import 'package:litgame_telegram/commands/system/gameflow.dart';
import 'package:litgame_telegram/commands/system/setorder.dart';
import 'package:litgame_telegram/router.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'commands/endgame.dart';
import 'commands/system/finishjoin.dart';
import 'commands/system/joinme.dart';
import 'commands/system/kickme.dart';
import 'commands/system/setmaster.dart';
import 'models/game/user.dart';

Future main(List<String> arguments) async {
  final parser = ArgParser();
  String botKey;
  String dataAppUrl;
  String dataAppKey;
  parser.addOption('botKey', abbr: 'k');
  parser.addOption('dataAppUrl', abbr: 'u');
  parser.addOption('dataAppKey', abbr: 'a');
  try {
    final results = parser.parse(arguments);
    botKey = results['botKey'];
    dataAppUrl = results['dataAppUrl'];
    dataAppKey = results['dataAppKey'];
  } on ArgumentError {
    print('--botKey option must be specified!');
    exit(1);
  } on ArgParserException {
    print('--botKey option must be specified!');
    exit(1);
  }
  await Parse().initialize(
    dataAppKey,
    dataAppUrl,
    debug: true,
    registeredSubClassMap: <String, ParseObjectConstructor>{
      'LitUsers': () => LitUser.clone(),
    },
  );

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
  router.registerCommand(SetOrderCmd());
  router.registerCommand(GameFlowCmd());

  stream.listen((Update data) {
    try {
      router.dispatch(data);
    } catch (exception) {
      var chatId = data.message?.chat.id ?? data.callback_query?.message.chat.id;
      telegram.sendMessage(chatId, exception.toString());
    }
  });
  await polling.start();
}
