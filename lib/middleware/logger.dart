import 'package:teledart/src/telegram/model.dart';
import 'package:teledart_app/teledart_app.dart';

class Logger with Middleware {
  @override
  void handle(Update data, TelegramEx telegram) {
    print(data.toJson());
  }
}
