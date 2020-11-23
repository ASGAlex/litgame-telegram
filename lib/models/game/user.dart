import 'package:teledart/model.dart';

class LitUser {
  static Map<String, int> _chatIdStorage = {};
  static Map<String, LitUser> _awaitForChatId = {};

  LitUser(this.telegramUser, {this.isAdmin = false, this.isGameMaster = false});

  bool isGameMaster = false;
  bool isAdmin = false;
  final User telegramUser;

  String getNickname() => "@" + telegramUser.username;

  int get chatId => _chatIdStorage[getNickname()];

  void set chatId(int id) {
    if (_awaitForChatId[getNickname()] == null) return;

    _chatIdStorage[getNickname()] = id;
    _awaitForChatId.remove(getNickname());
  }

  void awaitChatId() {
    _awaitForChatId[getNickname()] = this;
  }

  @override
  bool operator ==(Object other) =>
      other is LitUser && other.telegramUser.id == telegramUser.id;
}
