import 'package:meta/meta.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

abstract class Command {
  String get name;

  void run(
    Message message,
    Telegram telegram,
  );

  @protected
  void checkGameChat(Message message) {
    if (message.chat == null) {
      throw "Эту команду надо не в личке запускать, а в чате с игроками ;-)";
    }
  }
}
