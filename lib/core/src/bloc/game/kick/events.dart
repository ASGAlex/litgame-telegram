part of 'process.dart';

class KickFromGameEvent extends LitGameEvent {
  KickFromGameEvent(LitUser triggeredBy, this.targetUser, [String? tag])
      : super(triggeredBy, tag);

  KickFromGameEvent.empty()
      : targetUser = LitUser.byId(0),
        super(LitUser.byId(0));

  final LitUser targetUser;

  @override
  Type get type => KickFromGameEvent.empty().runtimeType;
}
