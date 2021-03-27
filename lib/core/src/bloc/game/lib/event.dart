import 'package:litgame_telegram/core/core.dart';

abstract class LitGameEvent extends Event {
  LitGameEvent(this.triggeredBy, [String? tag]) : super(tag);

  final LitUser triggeredBy;
}
