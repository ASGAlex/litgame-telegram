import 'package:litgame_telegram/core/core.dart';

abstract class LitGameEvent extends Event {
  LitGameEvent(this.triggeredBy, [String? tag]) : super(tag);

  final LitUser triggeredBy;
}

class ProcessInitEvent extends LitGameEvent {
  ProcessInitEvent([String? tag]) : super(LitUser.clone(), tag);

  @override
  int get type => TYPE;
  static const TYPE = 0;
}
