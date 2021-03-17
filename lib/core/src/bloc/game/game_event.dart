part of 'game_bloc.dart';

class GameEvent {
  GameEvent(this.triggeredBy);

  final LitUser triggeredBy;
}

/// Игра запущена
class StartNewGameEvent extends GameEvent {
  StartNewGameEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Игра остановлена
class StopGameEvent extends GameEvent {
  StopGameEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Игрок подключился к игре
class JoinGameEvent extends GameEvent {
  JoinGameEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Игрок отключил себя от игры
class KickFromGameEvent extends GameEvent {
  KickFromGameEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Окончен набор игроков в новую игру
class FinishJoinEvent extends GameEvent {
  FinishJoinEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Выбран игромастер
class SelectMasterEvent extends GameEvent {
  SelectMasterEvent(LitUser triggeredBy, this.master) : super(triggeredBy);

  final LitUser master;
}

/// Выбран игромастер
class SelectAdminEvent extends GameEvent {
  SelectAdminEvent(LitUser triggeredBy, this.admin) : super(triggeredBy);

  final LitUser admin;
}

/// Задан порядок хода для указанного игрока
class SortPlayerEvent extends GameEvent {
  SortPlayerEvent(LitUser triggeredBy, this.sortedPlayer) : super(triggeredBy);

  final LitUser sortedPlayer;
}

/// Сброшены настройки очередности хождения игроков
class ResetPlayersOrderEvent extends GameEvent {
  ResetPlayersOrderEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Запуск разминки с использованием указанной коллекции карт.
/// Указанная коллекция в дальнейшем будет использована и в самой игре
class TrainingStartEvent extends GameEvent {
  TrainingStartEvent(LitUser triggeredBy, this.collectionId)
      : super(triggeredBy);
  final String? collectionId;
}

/// Игрок окончил свой ход и передал другому
class TrainingNextTurnEvent extends GameEvent {
  TrainingNextTurnEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Старт, собственно, игры, окончание разминки, если была.
class GameFlowStartEvent extends GameEvent {
  GameFlowStartEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Игрок окончил свой рассказ, передал ход следующему
class GameFlowNextTurnEvent extends GameEvent {
  GameFlowNextTurnEvent(LitUser triggeredBy) : super(triggeredBy);
}

/// Игрок, чей сейчас ход, выбрал колоду, из которой будет тянуться карта
class GameFlowCardSelectedEvent extends GameEvent {
  GameFlowCardSelectedEvent(LitUser triggeredBy, this.cardType)
      : super(triggeredBy);
  final String cardType;
}

/// Возвращает сохранённое предыдущее состояние, если есть
class RestoreLastStateEvent extends GameEvent {
  RestoreLastStateEvent(LitUser triggeredBy) : super(triggeredBy);
}
