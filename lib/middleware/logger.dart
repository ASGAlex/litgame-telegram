// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

class Logger with Middleware {
  @override
  void handle(Update data, TelegramEx telegram) {
    print(data.toJson());
  }
}
