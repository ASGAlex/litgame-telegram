// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/models/cards/card.dart';
import 'package:litgame_telegram/models/cards/card_collection.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/game_flow.dart';
import 'package:litgame_telegram/models/game/traning_flow.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:meta/meta.dart';

part 'exceptions.dart';
part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(GameState initialState, this.game) : super(initialState);

  final LitGame game;

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    try {
      switch (event.runtimeType) {

        /// Начало новой игры. Игрок, сделавший запрос, подключается к игре и
        /// делается админом, запускается процесс инвайта остальных игроков.
        /// В [InvitingGameState] находимся, пока происходит подключение
        case StartNewGameEvent:
          event.triggeredBy.isAdmin = true;
          game.addPlayer(event.triggeredBy);
          yield InvitingGameState(
              game.id, event.triggeredBy, false, LitUser.clone());
          break;

        /// Добавление игрока в игру и возврат в состояние принятия инвайтов
        case JoinGameEvent:
          if (state is InvitingGameState) {
            final success = game.addPlayer(event.triggeredBy);
            yield InvitingGameState(
                game.id, event.triggeredBy, success, event.triggeredBy);
          }
          break;

        /// Удаление из игры. Если это был админ, то игра останавливается.
        /// Возвращение в состояние принятия инвайтов
        case KickFromGameEvent:
          final user = game.players[event.triggeredBy.chatId];
          if (user?.isAdmin == true) {
            LitGame.stopGame(game.id);
            yield NoGameState(event.triggeredBy);
          } else if (user != null) {
            var success = game.removePlayer(user);
            yield InvitingGameState(
                game.id, event.triggeredBy, success, event.triggeredBy);
          }
          break;

        /// Остановка игры и очистка ресурсов.
        /// Перевод в состояние "отсутствие игры"
        case StopGameEvent:
          final player = game.players[event.triggeredBy.chatId];
          if (player != null && player.isAdmin) {
            LitGame.stopGame(game.id);
            GameFlow.stopGame(game.id);
            TrainingFlow.stopGame(game.id);
            yield NoGameState(event.triggeredBy);
          } else {
            addError(BlocError(
                messageForGroup:
                    'У тебя нет власти надо мной! Пусть админ игры её остановит.'));
          }
          break;

        /// Завершение приёма игроков. Перевод в сотояние выбора игромастера
        case FinishJoinEvent:
          if (state is InvitingGameState && event.triggeredBy == game.admin) {
            yield SelectGameMasterState(game.id, event.triggeredBy);
          } else {
            addError(BlocError(
                messageForGroup:
                    'Пресечена незаконная попытка остановить набор игроков!'));
          }
          break;

        /// Установка пользователя игромастером.
        /// Перевод в состояние выбора очерёдности ходов игроков.
        case SelectMasterEvent:
          event as SelectMasterEvent;
          if (event.triggeredBy.isAdmin) {
            event.master.isGameMaster = true;
            if (state is SelectGameMasterState) {
              game.playersSorted.add(LinkedUser(event.master));
              yield PlayerSortingState(game.id, event.triggeredBy, false);
            } else {
              // игромастера сменили посередине игры, нужнро вывести сообщение
              // и венруть предыдущее состояние.
            }
          } else {
            addError(BlocError(
                messageForGroup:
                    'Данная операция доступна только администратору!'));
          }
          break;

        /// Сброс установленного состояния сортировки игроков.
        /// Автоматическое добавление гейм-мастера в качестве первого ходящего.
        /// Возврат в состояние сортировки игроков
        case ResetPlayersOrderEvent:
          game.playersSorted.clear();
          game.playersSorted.add(LinkedUser(game.master));
          yield PlayerSortingState(game.id, event.triggeredBy, false);
          break;

        /// В процессе сортировки игрок был указан, как следующий ходящий.
        /// Возврати в состояние сортировки игроков
        case SortPlayerEvent:
          event as SortPlayerEvent;
          game.playersSorted.add(LinkedUser(event.sortedPlayer));
          final isAllSorted = game.playersSorted.length == game.players.length;
          yield PlayerSortingState(game.id, event.triggeredBy, isAllSorted);
          break;

        /// Запущена разминка
        /// Коллекцию для разминки передаём в дополнительных параметрах, процесс
        /// выбора коллекции не входит в основной flow приложения
        case TrainingStartEvent:
          event as TrainingStartEvent;
          var collectionName = 'default';
          if (event.collectionId != null) {
            await CardCollection.getName(event.collectionId as String)
                .then((collection) {
              collectionName = collection.name;
            });
          }

          await game.gameFlowFactory(collectionName);
          yield TrainingFlowState(
              game.id, event.triggeredBy, await game.trainingFlow);

          break;

        /// Игрок закончил свой рассказ на разминке и передал ход следующему.
        case TrainingNextTurnEvent:
          final trainingFlow = await game.trainingFlow;
          trainingFlow.nextTurn();
          yield TrainingFlowState(
              game.id, event.triggeredBy, await trainingFlow);

          break;

        /// Игромастером запущен основной процесс игры.
        /// Игромастеру выкидываются рандомно три карты, по которым
        /// он сразу должен начать рассказывать историю
        /// Переход в состояние рассказа истории
        case GameFlowStartEvent:
          TrainingFlow.stopGame(game.id);
          final gameFlow = await game.gameFlowFactory();

          final cGeneric = gameFlow.getCard(CardType.generic);
          final cPlace = gameFlow.getCard(CardType.place);
          final cPerson = gameFlow.getCard(CardType.person);

          final selectedCards = <Card>[cGeneric, cPlace, cPerson];
          yield GameFlowMasterInitStory(
              game.id, event.triggeredBy, selectedCards);
          break;

        /// Игрок закончил рассказывать историю и пережал ход следующему игроку.
        /// Следующий игрок теперь должен вытянуть карту из одной из трёх колод.
        /// Перевод в состояние выбора карты
        case GameFlowNextTurnEvent:
          game.gameFlow.nextTurn();
          yield GameFlowPlayerSelectCard(game.id, event.triggeredBy);
          break;

        /// Игрок выбрал карту
        /// Выбранная карта показывается всем игрокам,
        /// игрок начинает рассказ. Перевод в состояние рассказа истории
        case GameFlowCardSelectedEvent:
          event as GameFlowCardSelectedEvent;
          final type = CardType.generic.getTypeByName(event.cardType);
          final card = game.gameFlow.getCard(type);
          yield GameFlowStoryTell(game.id, event.triggeredBy, card);
          break;
      }
    } catch (exception) {
      if (exception is GameBaseException) {
        print(exception);
        return;
      } else {
        rethrow;
      }
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    //keep to avoid exceptions
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onError(this, error, stackTrace);
  }
}
