import 'package:args/args.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:meta/meta.dart';
import 'package:teledart/src/telegram/model.dart';

import '../telegram.dart';

typedef CmdAction = Function(Message message, LitTelegram telegram);

abstract class ComplexCommand extends Command {
  ComplexCommand();

  ComplexCommand.args(ArgResults? arguments) : super.args(arguments);

  @override
  @mustCallSuper
  ArgParser getParser() {
    var parser = ArgParser();
    parser.addOption('action');
    return parser;
  }

  Map<String, CmdAction> get actionMap;

  String get action => arguments?['action'] ?? '';

  late final Message message;
  late final LitTelegram telegram;

  @override
  @mustCallSuper
  void run(Message message, LitTelegram telegram) {
    try {
      this.message = message;
      this.telegram = telegram;
    } catch (e) {}

    final actionFunc = actionMap[action];
    if (actionFunc != null && actionFunc is Function) {
      actionFunc(message, telegram);
    } else {
      onNoAction(message, telegram);
    }
  }

  void onNoAction(Message message, LitTelegram telegram);

  @mustCallSuper
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    parameters['action'] = actionName;
    return buildCommandCall(parameters);
  }
}