part of 'process.dart';

class FinishJoinEvent extends LitGameEvent {
  FinishJoinEvent(LitUser triggeredBy) : super(triggeredBy);

  FinishJoinEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => FinishJoinEvent.empty().runtimeType;
}

class SelectGameMasterEvent extends LitGameEvent {
  SelectGameMasterEvent(LitUser triggeredBy, this.userToBeMaster)
      : super(triggeredBy);

  SelectGameMasterEvent.empty()
      : userToBeMaster = LitUser.byId(0),
        super(LitUser.byId(0));

  final LitUser userToBeMaster;

  @override
  Type get type => SelectGameMasterEvent.empty().runtimeType;
}

class SortPlayerEvent extends LitGameEvent {
  SortPlayerEvent(LitUser triggeredBy, this.sortedPlayer) : super(triggeredBy);

  final LitUser sortedPlayer;

  SortPlayerEvent.empty()
      : sortedPlayer = LitUser.byId(0),
        super(LitUser.byId(0));

  @override
  Type get type => SortPlayerEvent.empty().runtimeType;
}

class ResetPlayersOrderEvent extends LitGameEvent {
  ResetPlayersOrderEvent(LitUser triggeredBy) : super(triggeredBy);

  ResetPlayersOrderEvent.empty() : super(LitUser.byId(0));

  @override
  Type get type => ResetPlayersOrderEvent.empty().runtimeType;
}
