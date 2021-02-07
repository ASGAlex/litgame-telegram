import 'package:litgame_telegram/botapp.dart';

Future main(List<String> arguments) async {
  final app = BotApp(BotAppConfig(arguments));
  app.run();
}
