import 'package:teledart/telegram.dart';

class LitTelegram extends Telegram {
  LitTelegram(String token)
      : _token = token,
        super(token);

  final String _token;

  String get token => _token;
}
