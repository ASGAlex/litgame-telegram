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
      Client.connect(redisConnectionString).then((value) {
        _client = value;
        commands = _client.asCommands<String, String>();
        completer.complete();
      });
    }
  }

  late final Client _client;
  late final Commands<String, String> commands;

  late final Future init;
}
