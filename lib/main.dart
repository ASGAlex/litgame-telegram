import 'dart:io';

import 'package:args/args.dart';
import 'package:litgame_telegram/commands/pm/addcollection.dart';
import 'package:litgame_telegram/commands/startgame.dart';
import 'package:litgame_telegram/commands/system/gameflow.dart';
import 'package:litgame_telegram/commands/system/setorder.dart';
import 'package:litgame_telegram/router.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';

import 'commands/endgame.dart';
import 'commands/system/finishjoin.dart';
import 'commands/system/joinme.dart';
import 'commands/system/kickme.dart';
import 'commands/system/setmaster.dart';
import 'models/cards/card.dart';
import 'models/cards/card_collection.dart';
import 'models/game/user.dart';

Future main(List<String> arguments) async {
  final parser = ArgParser();
  String botKey;
  String dataAppUrl;
  String dataAppKey;
  String parseMasterKey;
  String parseRestKey;
  parser.addOption('botKey', abbr: 'k');
  parser.addOption('dataAppUrl', abbr: 'u');
  parser.addOption('dataAppKey', abbr: 'a');
  parser.addOption('adminUserIds', abbr: 'i');
  parser.addOption('parseMasterKey', abbr: 'm');
  parser.addOption('parseRestKey', abbr: 'r');
  try {
    final results = parser.parse(arguments);
    botKey = results['botKey'];
    dataAppUrl = results['dataAppUrl'];
    dataAppKey = results['dataAppKey'];
    parseMasterKey = results['parseMasterKey'];
    parseRestKey = results['parseRestKey'];
    LitUser.adminUsers =
        results['adminUserIds'].toString().split(',').map((e) => int.parse(e)).toList();
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
    masterKey: parseMasterKey,
    clientKey: parseRestKey,
    debug: true,
    registeredSubClassMap: <String, ParseObjectConstructor>{
      'LitUsers': () => LitUser.clone(),
      'Card': () => Card.clone(),
      'CardCollection': () => CardCollection.clone(),
    },
  );

  final telegram = LitTelegram(botKey);
  final polling = LongPolling(telegram);
  Stream<Update> stream = polling.onUpdate();

  final router = Router(telegram);
  router.registerCommand(() => StartGameCmd());
  router.registerCommand(() => EndGameCmd());
  router.registerCommand(() => JoinMeCmd());
  router.registerCommand(() => KickMeCmd());
  router.registerCommand(() => FinishJoinCmd());
  router.registerCommand(() => SetMasterCmd());
  router.registerCommand(() => SetOrderCmd());
  router.registerCommand(() => GameFlowCmd());
  router.registerCommand(() => AddCollectionCmd());

  stream.listen((Update data) {
    try {
      router.dispatch(data);
    } catch (exception) {
      var chatId = data.message?.chat.id ?? data.callback_query?.message.chat.id;
      telegram.sendMessage(chatId, exception.toString());
      // rethrow;
    }
  });
  await polling.start();
}
