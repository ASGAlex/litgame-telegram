// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/core/core.dart';
import 'package:meta/meta.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends BusinessProcess<GameEvent> {
  GameBloc(GameState initialState, this.game) : super(initialState);

  final LitGame game;

  @override
  Stream<GameState> _mapEventToState(GameEvent event) async* {
    try {
      switch (event.runtimeType) {

        /// Начало новой игры. Игрок, сделавший запрос, подключается к игре и
        /// делается админом, запускается процесс инвайта остальных игроков.
        /// В [InvitingGameState] находимся, пока происходит подключение
        case StartNewGameEvent:
          break;

        /// Добавление игрока в игру и возврат в состояние принятия инвайтов
        case JoinGameEvent:
          break;

        /// Удаление из игры. Если это был админ, то игра останавливается.
        /// Возвращение в состояние принятия инвайтов
        case KickFromGameEvent:
          final newState =
              onKickFromGame(event as KickFromGameEvent, event.triggeredBy);
          if (newState != null) {
            yield newState;
          }
          break;

        /// Остановка игры и очистка ресурсов.
        /// Перевод в состояние "отсутствие игры"
        case StopGameEvent:
          break;

        /// Завершение приёма игроков. Перевод в сотояние выбора игромастера
        case FinishJoinEvent:
          break;

        /// Установка пользователя игромастером.
        /// Перевод в состояние выбора очерёдности ходов игроков.
        case SelectMasterEvent:
          break;

        /// Установка пользователя игромастером.
        /// Перевод в состояние выбора очерёдности ходов игроков.
        case SelectAdminEvent:
          event as SelectAdminEvent;
          event.admin.isAdmin = true;
          event.triggeredBy.isAdmin = false;
          add(RestoreLastStateEvent(event.triggeredBy));

          break;

        /// Сброс установленного состояния сортировки игроков.
        /// Автоматическое добавление гейм-мастера в качестве первого ходящего.
        /// Возврат в состояние сортировки игроков
        case ResetPlayersOrderEvent:
          break;

        /// В процессе сортировки игрок был указан, как следующий ходящий.
        /// Возврати в состояние сортировки игроков
        case SortPlayerEvent:
          break;

        /// Запущена разминка
        /// Коллекцию для разминки передаём в дополнительных параметрах, процесс
        /// выбора коллекции не входит в основной flow приложения
        case TrainingStartEvent:
          break;

        /// Игрок закончил свой рассказ на разминке и передал ход следующему.
        case TrainingNextTurnEvent:
          break;

        /// Игромастером запущен основной процесс игры.
        /// Игромастеру выкидываются рандомно три карты, по которым
        /// он сразу должен начать рассказывать историю
        /// Переход в состояние рассказа истории
        case GameFlowStartEvent:
          break;

        /// Игрок закончил рассказывать историю и пережал ход следующему игроку.
        /// Следующий игрок теперь должен вытянуть карту из одной из трёх колод.
        /// Перевод в состояние выбора карты
        case GameFlowNextTurnEvent:
          break;

        /// Игрок выбрал карту
        /// Выбранная карта показывается всем игрокам,
        /// игрок начинает рассказ. Перевод в состояние рассказа истории
        case GameFlowCardSelectedEvent:
          break;

        case RestoreLastStateEvent:
          if (_lastState != null) {
            yield _lastState as GameState;
            _lastState = null;
          }
          break;
      }
    } catch (exception) {
      print(exception);
      rethrow;
    }
  }

  GameState? onKickFromGame(KickFromGameEvent event, LitUser target) {
    final user = game.players[target.chatId];
    if (user?.isAdmin == true) {
      if (game.players.length == 1) {
        LitGame.stopGame(game.id);
        return NoGameState(event.triggeredBy);
      } else {
        game.removePlayer(user as LitUser);
        try {
          final linkedUser =
              game.playersSorted.firstWhere((element) => element.user == user);
          game.playersSorted.remove(linkedUser);
        } catch (_) {}
        _lastState = state;
        return SelectAdminState(game.id, event.triggeredBy);
      }
    } else if (user != null) {
      if (state is InvitingGameState || state is SelectGameMasterState) {
        var success = game.removePlayer(user);
        return InvitingGameState(game.id, event.triggeredBy, success, user);
      } else {
        var canContinue = true;
        try {
          final linkedUser =
              game.playersSorted.firstWhere((element) => element.user == user);
          game.playersSorted.remove(linkedUser);
        } catch (_) {
          if (state.runtimeType != PlayerSortingState) {
            addError(BlocError(
                messageForGroup: 'Не удалось кикнуть игрока ${user.nickname}'));
            canContinue = false;
          }
        }

        if (canContinue) {
          var success = game.removePlayer(user);
          return PlayerKickedDuringGame(
              game.id, event.triggeredBy, success, user);
        }
      }
    }
  }

  @override
  // ignore: must_call_super
  void onError(Object error, StackTrace stackTrace) {
    //keep to avoid exceptions
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onError(this, error, stackTrace);
  }
}
