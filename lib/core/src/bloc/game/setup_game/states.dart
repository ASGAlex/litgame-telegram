part of 'process.dart';

class InvitingGameState extends LitGameState {
  InvitingGameState([this.lastProcessedUser, this.lastOperationSuccess])
      : super();

  final bool? lastOperationSuccess;
  final LitUser? lastProcessedUser;

  @override
  List get acceptedEvents =>
      [JoinGameEvent.empty().runtimeType, FinishJoinEvent.empty().runtimeType];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    if (event is JoinGameEvent) {
      final main = bp.parent as MainProcess;
      main.bpInvite.add(event);
    }

    if (event is FinishJoinEvent) {
      if (event.triggeredBy.isAdmin) {
        return SelectGameMasterState();
      } else {
        addError(BlocError(
            messageForGroup:
                'Пресечена незаконная попытка остановить набор игроков!'));
      }
    }
  }
}

class SelectGameMasterState extends LitGameState {
  @override
  List get acceptedEvents => [SelectGameMasterEvent.empty().runtimeType];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    if (event is SelectGameMasterEvent) {
      if (event.triggeredBy.isAdmin) {
        event.userToBeMaster.isGameMaster = true;
        bp.game.playersSorted.add(LinkedUser(event.userToBeMaster));
        return PlayerSortingState();
      } else {
        addError(BlocError(
            messageForGroup:
                'Пресечена незаконная попытка назначить игромастера!'));
      }
    }
  }
}

class PlayerSortingState extends LitGameState {
  PlayerSortingState([this.isAllSorted = false]) : super();

  final bool isAllSorted;

  @override
  List get acceptedEvents => [
        SortPlayerEvent.empty().runtimeType,
        ResetPlayersOrderEvent.empty().runtimeType
      ];

  @override
  LitGameState? onEvent(LitGameEvent event, GameBaseProcess bp) {
    if (event.triggeredBy.isAdmin) {
      if (event is SortPlayerEvent) {
        bp.game.playersSorted.add(LinkedUser(event.sortedPlayer));
        final sorted = bp.game.playersSorted.length == bp.game.players.length;
        return PlayerSortingState(sorted);
      }

      if (event is ResetPlayersOrderEvent) {
        bp.game.playersSorted.clear();
        bp.game.playersSorted.add(LinkedUser(bp.game.master));
        return PlayerSortingState();
      }
    } else {
      addError(BlocError(
          messageForGroup:
              'Кто-то, кто не админ, пытался сортировать игроков о_О'));
    }
  }
}
