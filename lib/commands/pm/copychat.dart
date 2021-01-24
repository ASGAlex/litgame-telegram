// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:args/args.dart';
import 'package:args/src/arg_parser.dart';
import 'package:litgame_telegram/commands/core_command.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/src/telegram/model.dart';

/// TODO: наверное, это ненужно, удалить.
@Deprecated('not useful')
class CopyChatCmd extends Command {
  CopyChatCmd();

  @override
  ArgParser? getParser() => getGameBaseParser();

  CopyChatCmd.args(ArgResults? arguments) : super.args(arguments);

  @override
  String get name => 'copychat';

  @override
  bool get system => false;

  @override
  void run(Message message, LitTelegram telegram) {
    if (message.chat.type != 'private') {
      telegram.sendMessage(message.chat.id, 'Давай поговорим об этом в личке?');
      return;
    }

    final user = LitUser(message.from);
    user.registrationChecked.then((value) {
      final copyChat = user.isCopyChatSet;
      user['copychat'] = !copyChat;
      if (user['copychat'] == true) {
        telegram.sendMessage(
            message.chat.id,
            'Теперь все сообщения из общего чата будут дублироваться сюда, в личку. '
            'Изменения вступят в силу на следующей игре. '
            'Чтобы отменить, повтори команду ещё раз.');
      } else {
        telegram.sendMessage(
            message.chat.id,
            'Сообщения из общего чата больше не будут дублироваться в личку. '
            'Изменения вступят в силу на следующей игре. '
            'Чтобы это изменить, повтори команду ещё раз.');
      }
      user.save();
    });
  }
}
