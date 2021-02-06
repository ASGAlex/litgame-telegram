import 'dart:io';

// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';
import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/commands/endgame.dart';
import 'package:litgame_telegram/commands/pm/addcollection.dart';
import 'package:litgame_telegram/commands/startgame.dart';
import 'package:litgame_telegram/commands/system/finishjoin.dart';
import 'package:litgame_telegram/commands/system/gameflow.dart';
import 'package:litgame_telegram/commands/system/joinme.dart';
import 'package:litgame_telegram/commands/system/kickme.dart';
import 'package:litgame_telegram/commands/system/setcollection.dart';
import 'package:litgame_telegram/commands/system/setmaster.dart';
import 'package:litgame_telegram/commands/system/setorder.dart';
import 'package:litgame_telegram/middleware/message_copy.dart';
import 'package:litgame_telegram/models/cards/card.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:litgame_telegram/router.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';

import 'commands/core_command.dart';
import 'commands/pm/help.dart';
import 'commands/system/trainingflow.dart';
import 'middleware/logger.dart';
import 'middleware/middleware.dart';

class BotApp {
  BotApp(this.arguments);

  final List<String> arguments;

  late String botKey;
  String? dataAppUrl;
  String? dataAppKey;
  String? parseMasterKey;
  String? parseRestKey;

  List<CommandConstructor> commands = [
    () => StartGameCmd(),
    () => EndGameCmd(),
    () => JoinMeCmd(),
    () => KickMeCmd(),
    () => FinishJoinCmd(),
    () => SetMasterCmd(),
    () => SetOrderCmd(),
    () => SetCollectionCmd(),
    () => TrainingFlowCmd(),
    () => GameFlowCmd(),
    () => AddCollectionCmd(),
    () => HelpCmd()
  ];

  List<MiddlewareConstructor> middleware = [
    () => ComplexCommand.withAction(() => HelpCmd(), 'firstRun') as Middleware,
    () => Logger(),
    () => MessageCopy()
  ];

  bool setupFromCliArguments() {
    final parser = ArgParser();
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
      LitUser.adminUsers = results['adminUserIds']
          .toString()
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
    } on ArgumentError {
      print('Missing CLI arguments');
      print(arguments);
      return false;
    } on ArgParserException {
      print('Missing CLI arguments');
      print(arguments);
      return false;
    }
    return true;
  }

  bool setupFromEnv() {
    final envVars = Platform.environment;
    //damn null safety!
    final _botKey = envVars['BOT_TELEGRAM_KEY'];
    if (_botKey == null) return false;
    botKey = _botKey;

    final _dataAppUrl = envVars['BOT_PARSESERVER_URL'];
    if (_dataAppUrl == null) return false;
    dataAppUrl = _dataAppUrl;

    final _dataAppKey = envVars['BOT_PARSESERVER_APP_KEY'];
    if (_dataAppKey == null) return false;
    dataAppKey = _dataAppKey;

    final _parseMasterKey = envVars['BOT_PARSESERVER_MASTER_KEY'];
    if (_parseMasterKey == null) return false;
    parseMasterKey = _parseMasterKey;

    final _parseRestKey = envVars['BOT_PARSESERVER_REST_KEY'];
    if (_parseRestKey == null) return false;
    parseRestKey = _parseRestKey;

    if (envVars['BOT_ADMIN_USER_IDS'] != null) {
      LitUser.adminUsers = envVars['BOT_ADMIN_USER_IDS']
          .toString()
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
    }
    return true;
  }

  void onError(Object exception, Update data, LitTelegram telegram) {
    var chatId = data.message?.chat.id ?? data.callback_query?.message.chat.id;
    telegram.sendMessage(chatId, exception.toString());
  }

  void run() async {
    var successSetup = setupFromCliArguments();
    if (!successSetup) {
      successSetup = setupFromEnv();
    }
    if (!successSetup) {
      print('Cant setup bot properly.');
      exit(1);
    }
    print('Setup finished successfully!');

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
    for (var cmdBuilder in commands) {
      router.registerCommand(cmdBuilder);
    }
    for (var cmdBuilder in middleware) {
      router.registerMiddleware(cmdBuilder);
    }
    print('${commands.length} commands registered');

    stream.listen((Update data) {
      try {
        router.dispatch(data);
      } catch (exception) {
        onError(exception, data, telegram);
      }
    });
    print('Listening for updates from Telegram...');
    await polling.start();
  }
}
