import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:litgame_telegram/services/redis.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';

class LitUser extends ParseObject implements ParseCloneable {
  static late List<int> adminUsers;

  LitUser.clone()
      : telegramUser = User(),
        chatId = -1,
        super('LitUser');

  LitUser.byId(int id)
      : chatId = id,
        telegramUser = User(),
        super('LitUser') {
    telegramUser.id = id;
    registrationChecked = _findInStorage();
    this['chatId'] = chatId;
  }

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
    final redis = Redis();
    redis.init.then((_) {
      redis.commands.set('chatId-$chatId', toRedis());
    });
    return save();
  }

  bool get isAllowedAddCollection => this['allowAddCollection'] ?? false;

  Future<bool> _findInStorage() {
    return _findInRedis().then((found) {
      if (!found) {
        return _findInParse();
      }
      return found;
    });
  }

  Future<bool> _findInRedis() {
    final redis = Redis();
    final searchFinished = Completer<bool>();
    var timeout = false;
    redis.init.then((_) {
      redis.commands.get('chatId-' + chatId.toString()).then((value) {
        if (value == null || timeout) {
          if (!searchFinished.isCompleted) {
            searchFinished.complete(false);
          }
          return;
        }
        fromRedis(value);
        if (!searchFinished.isCompleted) {
          searchFinished.complete(true);
        }
      });
    });
    Future.delayed(Duration(milliseconds: 10)).then((_) {
      if (!searchFinished.isCompleted) {
        searchFinished.complete(false);
      }
      timeout = true;
    });
    return searchFinished.future;
  }

  Future<bool> _findInParse() {
    final redis = Redis();
    final builder = QueryBuilder<LitUser>(LitUser.clone())
      ..whereEqualTo('chatId', chatId);
    return builder.query().then((ParseResponse response) {
      if (response.results == null) return false;
      if (response.results.isNotEmpty) {
        this['objectId'] = response.results.first['objectId'];
        this['allowAddCollection'] = response.results.first['allowAddCollection'];
        redis.init.then((_) {
          redis.commands.set('chatId-$chatId', toRedis());
        });
        return true;
      }
      return false;
    });
  }

  String toRedis() {
    final _json = <String, String>{};
    _json['objectId'] = this['objectId'] ?? (-1).toString();
    _json['allowAddCollection'] = (this['allowAddCollection'] ?? false).toString();
    return jsonEncode(_json);
  }

  void fromRedis(String value) {
    final _json = jsonDecode(value);
    this['objectId'] = _json['objectId'] ?? -1;
    this['allowAddCollection'] = _json['allowAddCollection'] ?? false;
  }
}

class LinkedUser extends LinkedListEntry<LinkedUser> {
  LinkedUser(this.user);

  final LitUser user;
}
