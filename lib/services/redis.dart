// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:async';
import 'dart:io';

import 'package:dartis/dartis.dart';

class Redis {
  static final _controller = Redis._instance();

  factory Redis() => _controller;

  Redis._instance() {
    final completer = Completer();
    init = completer.future;
    final envVars = Platform.environment;
    var redisConnectionString = envVars['REDISCLOUD_URL'];
    if (redisConnectionString != null && redisConnectionString.isNotEmpty) {
      print('Connecting to Redis: $redisConnectionString');
      Client.connect(redisConnectionString).then((value) {
        _client = value;

        // additional authorisation needed since redis 6.
        // see https://redis.io/topics/acl for details
        final parsed = Uri.parse(redisConnectionString);
        if (parsed.userInfo.isNotEmpty) {
          var parts = parsed.userInfo.split(':');
          if (parts.length == 2) {
            // final rUser = parts.first;
            final rPassword = parts.last;
            _client.asCommands().auth(rPassword);
          }
        }
        commands = _client.asCommands<String, String>();
        completer.complete();
      });
    }
  }

  late final Client _client;
  late final Commands<String, String> commands;

  late final Future init;
}
