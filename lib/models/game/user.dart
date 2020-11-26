import 'package:teledart/model.dart';

class LitUser {
  static final Map<int, int> _chatIdStorage = {};

  LitUser(this.telegramUser, {this.isAdmin = false, this.isGameMaster = false}) {
    chatId = telegramUser.id;
  }

  bool isGameMaster = false;
  bool isAdmin = false;
  final User telegramUser;

  String get nickname => '@' + (telegramUser.username ?? telegramUser.first_name);

  String get fullName => telegramUser.first_name + (telegramUser.last_name ?? '');

  int get chatId => _chatIdStorage[telegramUser.id] ?? -1;

  bool get noChatId => chatId < 0;

  set chatId(int id) {
    _chatIdStorage[telegramUser.id] = id;
  }

  @override
  bool operator ==(Object other) =>
      other is LitUser && other.telegramUser.id == telegramUser.id;
  //
  // static Future loadChatIdStorage() {
  //   return Firestore.get(collection: 'chatIdStorage').then((query) {
  //     print(query);
  //     for (var doc in query) {
  //       if (doc['nickname'] == null || doc['chatId'] == null || doc['chatId'] == -1) {
  //         continue;
  //       }
  //       _chatIdStorage[doc['nickname']] = doc['chatId'];
  //     }
  //   });
  // }
  //
  // static void saveChatIdStorage() {
  //   for (var chatIdEntry in _chatIdStorage.entries) {
  //     Firestore.add(
  //         collection: 'chatIdStorage',
  //         id: 'user-' + chatIdEntry.key.toString(),
  //         body: {'chatId': chatIdEntry.key.toString()});
  //   }
  // }
}
