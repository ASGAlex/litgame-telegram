import 'package:litgame_telegram/commands/middleware.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/src/telegram/model.dart';

class Logger with Middleware {
  @override
  void handle(Update data, LitTelegram telegram) {
    print(data.toJson());
  }
}
