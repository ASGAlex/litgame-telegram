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

  void addEvent(GameEventType type, LitUser triggeredBy,
      [dynamic additionalData]) {
    super.add(GameEvent(type, triggeredBy, additionalData));
  }

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    try {
      switch (event.type) {

        /// Начало новой игры. Игрок, сделавший запрос, подключается к игре и
        /// делается админом, запускается процесс инвайта остальных игроков.
        /// В [InvitingGameState] находимся, пока происходит подключение
        case GameEventType.startNewGame:
          game.addPlayer(event.triggeredBy);
          yield InvitingGameState(game.id, event.triggeredBy);
          break;

        /// Добавление игрока в игру и возврат в состояние принятия инвайтов
        case GameEventType.joinGame:
          if (state is InvitingGameState) {
            final result = game.addPlayer(event.triggeredBy);
            yield InvitingGameState(
                game.id, event.triggeredBy, result, event.triggeredBy);
          }
          break;

        /// Удаление из игры. Если это был админ, то игра останавливается.
        /// Возвращение в состояние принятия инвайтов
        case GameEventType.kickFromGame:
          final user = game.players[event.triggeredBy.chatId];
          if (user?.isAdmin == true) {
            LitGame.stopGame(game.id);
            yield NoGameState(event.triggeredBy);
          } else if (user != null) {
            game.removePlayer(user);
            yield PlayerInvitedIntoGameState(game.id, event.triggeredBy);
          }
          break;

        /// Остановка игры и очистка ресурсов.
        /// Перевод в состояние "отсутствие игры"
        case GameEventType.stopGame:
          final player = game.players[event.triggeredBy.chatId];
          if (player != null && player.isAdmin) {
            LitGame.stopGame(game.id);
            GameFlow.stopGame(game.id);
            TrainingFlow.stopGame(game.id);
            yield NoGameState(event.triggeredBy);
          } else {
            yield GameState.WithError(state,
                messageForGroup:
                    'У тебя нет власти надо мной! Пусть админ игры её остановит.');
          }
          break;

        /// Завершение приёма игроков. Перевод в сотояние выбора игромастера
        case GameEventType.finishJoin:
          if (state is InvitingGameState && event.triggeredBy == game.admin) {
            yield SelectGameMasterState(game.id, event.triggeredBy);
          } else {
            yield GameState.WithError(state,
                messageForGroup:
                    'Пресечена незаконная попытка остановить набор игроков!');
          }
          break;

        /// Установка пользователя игромастером.
        /// Перевод в состояние выбора очерёдности ходов игроков.
        case GameEventType.selectMaster:
          if (event.triggeredBy.isAdmin) {
            final master = event.additionalData as LitUser;
            master.isGameMaster = true;
            yield PlayerSortingState(game.id, event.triggeredBy, false);
          } else {
            yield GameState.WithError(state,
                messageForGroup:
                    'Данная операция доступна только администратору!');
          }
          break;

        /// Сброс установленного состояния сортировки игроков.
        /// Автоматическое добавление гейм-мастера в качестве первого ходящего.
        /// Возврат в состояние сортировки игроков
        case GameEventType.resetPlayersOrder:
          game.playersSorted.clear();
          game.playersSorted.add(LinkedUser(game.master));
          yield PlayerSortingState(game.id, event.triggeredBy, false);
          break;

        /// В процессе сортировки игрок был указан, как следующий ходящий.
        /// Возврати в состояние сортировки игроков
        case GameEventType.sortPlayer:
          final player = event.additionalData as LitUser;
          game.playersSorted.add(LinkedUser(player));
          final isAllSorted = game.playersSorted.length == game.players.length;
          yield PlayerSortingState(game.id, event.triggeredBy, isAllSorted);
          break;

        /// Запущена разминка
        /// Коллекцию для разминки передаём в дополнительных параметрах, процесс
        /// выбора коллекции не входит в основной flow приложения
        case GameEventType.trainingStart:
          var collectionName = 'default';
          if (event.additionalData != null) {
            await CardCollection.getName(event.additionalData)
                .then((collection) {
              collectionName = collection.name;
            });
          }

          await game.gameFlowFactory(collectionName);
          yield TrainingFlowState(
              game.id, event.triggeredBy, await game.trainingFlow);

          break;

        /// Игрок закончил свой рассказ на разминке и передал ход следующему.
        case GameEventType.trainingNextTurn:
          final trainingFlow = await game.trainingFlow;
          trainingFlow.nextTurn();
          yield TrainingFlowState(
              game.id, event.triggeredBy, await trainingFlow);

          break;

        /// Завершение разминки администратором
        /// FIXME: перевод в каой-то странный стейт, почему бы сразу не начать игру?
        case GameEventType.trainingEnd:
          TrainingFlow.stopGame(game.id);
          yield TrainingFlowState(
              game.id, event.triggeredBy, await game.trainingFlow);

          break;

        /// Игромастером запущен основной процесс игры.
        /// Игромастеру выкидываются рандомно три карты, по которым
        /// он сразу должен начать рассказывать историю
        /// Переход в состояние рассказа истории
        case GameEventType.gameFlowStart:
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
        case GameEventType.gameFlowNextTurn:
          game.gameFlow.nextTurn();
          yield GameFlowPlayerSelectCard(game.id, event.triggeredBy);
          break;

        /// Игрок выбрал карту
        /// Выбранная карта показывается всем игрокам,
        /// игрок начинает рассказ. Перевод в состояние рассказа истории
        case GameEventType.gameFlowCardSelected:
          final type = CardType.generic.getTypeByName(event.additionalData);
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
}
