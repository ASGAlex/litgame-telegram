import 'package:litgame_telegram/core/core.dart';

class BlocError {
  BlocError(this.event, {this.messageForUser, this.messageForGroup});

  LitGameEvent event;
  Object? messageForUser;
  Object? messageForGroup;
}
