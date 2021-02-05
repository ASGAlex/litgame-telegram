import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';

typedef MiddlewareConstructor = Middleware Function();

mixin Middleware {
  void handle(Update data, LitTelegram telegram);
}
