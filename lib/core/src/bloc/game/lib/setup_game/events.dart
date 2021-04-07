part of 'process.dart';

enum SetupGameEvent {
  finishJoin,
  selectGameMaster,
  sortPlayer,
  resetPlayerOrder,
  askAdmin
}

class FinishJoinEvent extends LitGameEvent {
  FinishJoinEvent(LitUser triggeredBy) : super(triggeredBy);

  @override
  dynamic get type => SetupGameEvent.finishJoin;
}

class SelectGameMasterEvent extends LitGameEvent {
  SelectGameMasterEvent(LitUser triggeredBy, this.userToBeMaster)
      : super(triggeredBy);
  final LitUser userToBeMaster;

  @override
  dynamic get type => SetupGameEvent.selectGameMaster;
}

class AskAdminEvent extends LitGameEvent {
  AskAdminEvent(LitUser triggeredBy, this.userToBeAdmin) : super(triggeredBy);
  final LitUser userToBeAdmin;

  @override
  dynamic get type => SetupGameEvent.askAdmin;
}

class SelectGameAdminEvent extends LitGameEvent {
  SelectGameAdminEvent(LitUser triggeredBy, this.userToBeAdmin)
      : super(triggeredBy);
  final LitUser userToBeAdmin;

  @override
  dynamic get type => SetupGameEvent.selectGameMaster;
}

class SortPlayerEvent extends LitGameEvent {
  SortPlayerEvent(LitUser triggeredBy, this.sortedPlayer) : super(triggeredBy);

  final LitUser sortedPlayer;

  @override
  dynamic get type => SetupGameEvent.sortPlayer;
}

class ResetPlayersOrderEvent extends LitGameEvent {
  ResetPlayersOrderEvent(LitUser triggeredBy) : super(triggeredBy);

  @override
  dynamic get type => SetupGameEvent.resetPlayerOrder;
}
