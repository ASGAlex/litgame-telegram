part of 'process.dart';

enum KickEvent { kick }

class KickFromGameEvent extends LitGameEvent {
  KickFromGameEvent(LitUser triggeredBy, this.targetUser, [String? tag])
      : super(triggeredBy, tag);

  final LitUser targetUser;

  @override
  dynamic get type => KickEvent.kick;
}
