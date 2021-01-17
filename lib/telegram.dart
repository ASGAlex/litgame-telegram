// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:teledart/telegram.dart';

class LitTelegram extends Telegram {
  LitTelegram(String token)
      : _token = token,
        super(token);

  final String _token;

  String get token => _token;
}

enum MarkdownV2EntityType { pre, code, textLink, none }

extension MarkdownV2 on String {
  String escapeMarkdownV2([MarkdownV2EntityType type = MarkdownV2EntityType.none]) {
    String whatToEscape;
    if ([MarkdownV2EntityType.code, MarkdownV2EntityType.pre].contains(type)) {
      whatToEscape = '\\`';
    } else if (type == MarkdownV2EntityType.textLink) {
      whatToEscape = '\\';
    } else {
      whatToEscape = '[]()`>#+-=|{}.!';
    }
    var escapedString = this;
    for (var i = 0; i < whatToEscape.length; i++) {
      escapedString = escapedString.replaceAll(whatToEscape[i], '\\${whatToEscape[i]}');
    }
    return escapedString;
  }
}
