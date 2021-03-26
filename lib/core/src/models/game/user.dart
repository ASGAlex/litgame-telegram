// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:litgame_telegram/core/core.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:teledart/model.dart';

//TODO: heavy refactoring needed
class LitUser extends ParseObject implements ParseCloneable {
  static late List<int> adminUsers;
  static final Map<int, Map<String, dynamic>> _usersDataCache = {};

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

  String get nickname =>
      '@' + (telegramUser.username ?? telegramUser.first_name);

  String get fullName =>
      telegramUser.first_name + ' ' + (telegramUser.last_name ?? '');

  bool get noChatId => chatId < 0;

  LitGame? currentGame;

  @override
  bool operator ==(Object other) =>
      other is LitUser && other.telegramUser.id == telegramUser.id;

  LitUser fromGame(LitGame game) {
    final gamePlayer = game.players[telegramUser.id];
    return gamePlayer ?? this;
  }

  Future<ParseResponse> allowAddCollection(bool allow) {
    this['allowAddCollection'] = allow;
    return save();
  }

  @override
  Future<ParseResponse> save() {
    final redis = Redis();
    redis.init.then((_) {
      redis.commands.set('chatId-$chatId', toRedis());
    });
    return super.save();
  }

  bool get isAllowedAddCollection => this['allowAddCollection'] ?? false;

  //FIXME: dirty hotfix
  bool get isCopyChatSet {
    return true;
    if (this['copychat'] is String) {
      this['copychat'] = this['copychat'] == 'true' ? true : false;
    }
    return this['copychat'] ?? false;
  }

  Future<bool> _findInStorage() async {
    var found = false;
    found = await _findInMemory();
    if (!found) {
      found = await _findInRedis();
      if (!found) {
        found = await _findInParse();
      }
    }
    return found;
  }

  Future<bool> _findInMemory() {
    final searchFinished = Completer<bool>();
    final userData = _usersDataCache[chatId];
    if (userData == null) {
      searchFinished.complete(false);
      return searchFinished.future;
    }
    this['objectId'] = userData['objectId'] ?? -1;
    this['allowAddCollection'] = userData['allowAddCollection'] ?? false;
    if (this['allowAddCollection'] is String) {
      this['allowAddCollection'] =
          this['allowAddCollection'] == 'true' ? true : false;
    }
    this['copychat'] = userData['copychat'] ?? false;
    if (this['copychat'] is String) {
      this['copychat'] = this['copychat'] == 'true' ? true : false;
    }
    searchFinished.complete(true);
    return searchFinished.future;
  }

  void _saveToMemory() {
    if (_usersDataCache.length > 10000) {
      var keysToDelete = <int>[];
      _usersDataCache.forEach((key, value) {
        final ts = value['ts'] as DateTime;
        if (DateTime.now().difference(ts).inDays > 10) {
          keysToDelete.add(key);
        }
      });
      keysToDelete.forEach((element) {
        _usersDataCache.remove(element);
      });
    }

    _usersDataCache[chatId] = {
      'copychat': this['copychat'] ?? false.toString(),
      'allowAddCollection': this['allowAddCollection'] ?? false.toString(),
      'objectId': this['objectId'] ?? (-1).toString(),
      'ts': DateTime.now()
    };
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
        _saveToMemory();
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

  void _saveToRedis() {
    final redis = Redis();
    redis.init.then((_) {
      redis.commands.set('chatId-$chatId', toRedis());
    });
  }

  Future<bool> _findInParse() {
    final builder = QueryBuilder<LitUser>(LitUser.clone())
      ..whereEqualTo('chatId', chatId);
    return builder.query().then((ParseResponse response) {
      if (response.results == null) return false;
      if (response.results.isNotEmpty) {
        this['objectId'] = response.results.first['objectId'];
        this['allowAddCollection'] =
            response.results.first['allowAddCollection'];
        this['copychat'] = response.results.first['copychat'];
        _saveToMemory();
        _saveToRedis();
        return true;
      }
      return false;
    });
  }

  String toRedis() {
    final _json = <String, String>{};
    _json['objectId'] = this['objectId'] ?? (-1).toString();
    _json['allowAddCollection'] =
        (this['allowAddCollection'] ?? false).toString();
    _json['copychat'] = (this['copychat'] ?? false).toString();
    return jsonEncode(_json);
  }

  void fromRedis(String value) {
    final _json = jsonDecode(value);
    this['objectId'] = _json['objectId'] ?? -1;
    this['allowAddCollection'] = _json['allowAddCollection'] ?? false;
    this['copychat'] = _json['copychat'] ?? false;
  }
}

class LinkedUser extends LinkedListEntry<LinkedUser> {
  LinkedUser(this.user);

  final LitUser user;
}
