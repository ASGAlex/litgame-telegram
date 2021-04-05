part of 'process.dart';

enum KickEvent { kick, kickStageFinished }

class KickFromGameEvent extends LitGameEvent {
  KickFromGameEvent(LitUser triggeredBy, this.targetUser, [String? tag])
      : super(triggeredBy, tag);

  final LitUser targetUser;

  @override
  dynamic get type => KickEvent.kick;
}

class KickStageFinished extends LitGameEvent {
  KickStageFinished(LitUser triggeredBy, this.stageProcessTag)
      : super(triggeredBy);

  String stageProcessTag;

  @override
  KickEvent get type => KickEvent.kickStageFinished;
}
