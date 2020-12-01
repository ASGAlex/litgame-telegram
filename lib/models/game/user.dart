import 'dart:collection';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';

class LitUser extends ParseObject implements ParseCloneable {
  static final Map<int, int> _chatIdStorage = {};

  LitUser.clone()
      : telegramUser = User(),
        super('LitUser');

  @override
  LitUser clone(Map<String, dynamic> map) => LitUser.clone()..fromJson(map);

  LitUser(this.telegramUser, {this.isAdmin = false, this.isGameMaster = false})
      : super('LitUser') {
    chatId = telegramUser.id;
    if (telegramUser.id != null) {
      registrationChecked = _findInStorage();
      this['chatId'] = chatId;
    }
  }

  late Future<bool> registrationChecked;
  bool isGameMaster = false;
  bool isAdmin = false;
  final User telegramUser;

  String get nickname => '@' + (telegramUser.username ?? telegramUser.first_name);

  String get fullName => telegramUser.first_name + ' ' + (telegramUser.last_name ?? '');

  int get chatId => _chatIdStorage[telegramUser.id] ?? -1;

  bool get noChatId => chatId < 0;

  set chatId(int id) {
    _chatIdStorage[telegramUser.id] = id;
  }

  @override
  bool operator ==(Object other) =>
      other is LitUser && other.telegramUser.id == telegramUser.id;

  // static Future loadChatIdStorage() async {
  //   var apiResponse = await LitUser.clone().getAll();
  //
  //   if (apiResponse.success) {
  //     for (var u in apiResponse.result) {
  //       print(u.toString());
  //       var user = u as User;
  //       await pa.delete();
  //     }
  //   }
  //
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
  Future<bool> _findInStorage() {
    final builder = QueryBuilder<LitUser>(LitUser.clone())
      ..whereEqualTo('chatId', chatId);
    return builder.query().then((ParseResponse response) {
      if (response.results == null) return false;
      if (response.results.isNotEmpty) {
        return true;
      }
      return false;
    });
  }
}

class LinkedUser extends LinkedListEntry<LinkedUser> {
  LinkedUser(this.user);

  final LitUser user;
}
