import 'dart:collection';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';

class LitUser extends ParseObject implements ParseCloneable {
  static late List<int> adminUsers;

  LitUser.clone([int _chatId = -1])
      : telegramUser = User(),
        chatId = _chatId,
        super('LitUser');

  @override
  LitUser clone(Map<String, dynamic> map) => LitUser.clone()..fromJson(map);

  LitUser(this.telegramUser, {this.isAdmin = false, this.isGameMaster = false})
      : chatId = telegramUser.id ?? -1,
        super('LitUser') {
    if (!noChatId) {
      registrationChecked = _findInStorage();
      this['chatId'] = chatId;
    }
  }

  late Future<bool> registrationChecked;
  bool isGameMaster = false;
  bool isAdmin = false;
  final User telegramUser;
  int chatId;

  String get nickname => '@' + (telegramUser.username ?? telegramUser.first_name);

  String get fullName => telegramUser.first_name + ' ' + (telegramUser.last_name ?? '');

  bool get noChatId => chatId < 0;

  @override
  bool operator ==(Object other) =>
      other is LitUser && other.telegramUser.id == telegramUser.id;

  Future<ParseResponse> allowAddCollection(bool allow) {
    this['allowAddCollection'] = allow;
    return save();
  }

  bool get isAllowedAddCollection => this['allowAddCollection'] ?? false;

  Future<bool> _findInStorage() {
    final builder = QueryBuilder<LitUser>(LitUser.clone())
      ..whereEqualTo('chatId', chatId);
    return builder.query().then((ParseResponse response) {
      if (response.results == null) return false;
      if (response.results.isNotEmpty) {
        this['allowAddCollection'] = response.results.first['allowAddCollection'];
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
