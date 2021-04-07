part of 'process.dart';

class SelectAdminWhilePlayingState extends LitGameState {
  @override
  List get acceptedEvents =>
      [SetupGameEvent.askAdmin, SetupGameEvent.selectGameMaster];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is SelectGameAdminEvent) {
      if (!event.triggeredBy.isAdmin) {
        addError(BlocError(event,
            messageForGroup:
                'Пресечена незаконная попытка назначить админа игры!'));
        return null;
      }

      if (bp.game.players[event.userToBeAdmin.chatId] == null) {
        addError(BlocError(event,
            messageForGroup:
                'Нельзя выбрать админом игрока, не подключённого к игре!'));
        return null;
      }

      event.userToBeAdmin.isAdmin = true;
    }
    bp.parent?.add(KickStageFinished(event.triggeredBy, bp.tag));
  }
}

class SelectMasterWhilePlayingState extends LitGameState {
  @override
  List get acceptedEvents => [SetupGameEvent.selectGameMaster];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is SelectGameMasterEvent) {
      if (!event.triggeredBy.isAdmin || !event.triggeredBy.isGameMaster) {
        addError(BlocError(event,
            messageForGroup:
                'Пресечена незаконная попытка назначить игромастера игры!'));
        return null;
      }

      if (bp.game.players[event.userToBeMaster.chatId] == null) {
        addError(BlocError(event,
            messageForGroup:
                'Нельзя выбрать игромастером игрока, не подключённого к игре!'));
        return null;
      }

      event.userToBeMaster.isGameMaster = true;
    }

    bp.parent?.add(KickStageFinished(event.triggeredBy, bp.tag));
  }
}
