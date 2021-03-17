import 'dart:io';

// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';
import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/core/core.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

import 'commands/commands.dart';
import 'game_event_observer.dart';
import 'middleware/logger.dart';
import 'middleware/message_copy.dart';

class BotApp extends TeledartApp {
  BotApp(this._conf) : super(_conf.botKey);

  final BotAppConfig _conf;

  @override
  List<CommandConstructor> commands = [
    () => StartGameCmd(),
    () => EndGameCmd(),
    () => JoinMeCmd(),
    () => KickMeCmd(),
    () => FinishJoinCmd(),
    () => SetMasterCmd(),
    () => SelectAdminCmd(),
    () => SetOrderCmd(),
    () => SetCollectionCmd(),
    () => TrainingFlowCmd(),
    () => GameFlowCmd(),
    () => AddCollectionCmd(),
    () => DelCollectionCmd(),
    () => HelpCmd(),
  ];

  @override
  List<MiddlewareConstructor> middleware = [
    () => ComplexCommand.withAction(() => HelpCmd(), 'firstRun') as Middleware,
    () => Logger(),
    () => MessageCopy()
  ];

  @override
  void onError(Object exception, Update data, TelegramEx telegram) {
    var chatId = data.message?.chat.id ?? data.callback_query?.message.chat.id;
    telegram.sendMessage(chatId, exception.toString());
  }

  @override
  void run() async {
    await Parse().initialize(
      _conf.dataAppKey,
      _conf.dataAppUrl,
      masterKey: _conf.parseMasterKey,
      clientKey: _conf.parseRestKey,
      debug: true,
      registeredSubClassMap: <String, ParseObjectConstructor>{
        'LitUsers': () => LitUser.clone(),
        'Card': () => Card.clone(),
        'CardCollection': () => CardCollection.clone(),
      },
    );

    Bloc.observer = GameEventObserver(telegram);
    super.run();
  }
}

class BotAppConfig {
  BotAppConfig(this.arguments) {
    var successSetup = _setupFromCliArguments();
    if (!successSetup) {
      successSetup = _setupFromEnv();
    }

    if (botKey == null) {
      successSetup = false;
    }
    if (!successSetup) {
      print('Cant setup bot properly.');
      exit(1);
    }
    print('Setup finished successfully!');
  }

  late String botKey;
  String? dataAppUrl;
  String? dataAppKey;
  String? parseMasterKey;
  String? parseRestKey;

  List<String>? arguments;

  bool _setupFromCliArguments() {
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

  bool _setupFromEnv() {
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
}
