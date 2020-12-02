import 'package:args/src/arg_parser.dart';
import 'package:args/src/arg_results.dart';
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

  @override
  @mustCallSuper
  void run(Message message, LitTelegram telegram) {
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
