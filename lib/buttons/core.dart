import 'package:litgame_telegram/models/game/game.dart';
import 'package:teledart/model.dart';
import 'package:teledart/telegram.dart';

abstract class ButtonCallback {
  ButtonCallback(this.messageId);

  final int messageId;

  void run(
    Message message,
    Telegram telegram,
  );
}

class ButtonCallbackController {
  static ButtonCallbackController _instance;

  factory ButtonCallbackController() {
    if (_instance == null) {
      _instance = ButtonCallbackController._singleton();
    }
    return _instance;
  }

  ButtonCallbackController._singleton();

  final Map<int, Map<int, ButtonCallback>> _buttonCallbacks = {};

  Map<int, Map<int, ButtonCallback>> get callbacks => _buttonCallbacks;

  void clearCallbacks(int chatId) {
    _buttonCallbacks.remove(chatId);
  }

  void registerCallback(int chatId, int messageId, ButtonCallback callback) {
    if (LitGame.find(chatId) == null) {
      throw "В этом чате нет запущенных игр";
    }
    _buttonCallbacks[chatId] = <int, ButtonCallback>{messageId: callback};
  }

  ButtonCallback getCallbackForMessage(Message message) {
    if (!_buttonCallbacks.containsKey(message.chat.id)) {
      throw "В этом чате нет запущенных игр";
    }
    if (!_buttonCallbacks[message.chat.id]
        .containsKey(message.reply_to_message.message_id)) {
      throw 'Кнопка "протухла"...';
    }

    return _buttonCallbacks[message.chat.id][message.reply_to_message.message_id];
  }
}
