import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/src/telegram/model.dart';
import 'package:test/test.dart';

class TestCommand extends Command {
  @override
  ArgParser? getParser() {
    var parser = ArgParser();
    parser.addOption('opt1');
    parser.addOption('opt2');
    return parser;
  }

  @override
  String get name => 'test';

  @override
  void run(Message message, LitTelegram telegram) {}
}

class TestActionCommand extends ComplexCommand {
  @override
  Map<String, CmdAction> get actionMap => {'testAction': onTestAction};

  void onTestAction(Message message, LitTelegram telegram) {}

  @override
  String get name => 'testAction';

  @override
  ArgParser getParser() {
    return super.getParser()..addOption('opt1')..addOption('opt2');
  }

  @override
  void onNoAction(Message message, LitTelegram telegram) {}
}

void main() {
  test('Arguments Factory test', () {
    final cmd = Command.withArguments(
        () => TestCommand(), {'opt1': 'option_1_Data', 'opt2': 'option_2_Data'});
    expect(cmd.arguments?['opt1'], 'option_1_Data');
    expect(cmd.arguments?['opt2'], 'option_2_Data');
  });

  test('Action Command Arguments Factory test', () {
    final cmd = ComplexCommand.withAction(() => TestActionCommand(), 'testAction',
        {'opt1': 'option_1_Data', 'opt2': 'option_2_Data'});

    expect(cmd.arguments?['action'], 'testAction');
    expect(cmd.arguments?['opt1'], 'option_1_Data');
    expect(cmd.arguments?['opt2'], 'option_2_Data');
  });
}
