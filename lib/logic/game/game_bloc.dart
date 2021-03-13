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
        case GameEventType.startNewGame:
          game.addPlayer(event.triggeredBy);
          yield InvitingGameState(game.chatId, event.triggeredBy);
          break;
        case GameEventType.stopGame:
          final player = game.players[event.triggeredBy.chatId];
          if (player != null && player.isAdmin) {
            LitGame.stopGame(game.chatId);
            GameFlow.stopGame(game.chatId);
            TrainingFlow.stopGame(game.chatId);
            yield NoGameState(event.triggeredBy);
          } else {
            yield GameState.WithError(state,
                messageForGroup:
                    'У тебя нет власти надо мной! Пусть админ игры её остановит.');
          }
          break;
        case GameEventType.joinGame:
          if (state is InvitingGameState) {
            final result = game.addPlayer(event.triggeredBy);
            yield InvitingGameState(
                game.chatId, event.triggeredBy, result, event.triggeredBy);
          }
          break;
        case GameEventType.kickFromGame:
          final user = game.players[event.triggeredBy.chatId];
          if (user?.isAdmin == true) {
            LitGame.stopGame(game.chatId);
            yield NoGameState(event.triggeredBy);
          } else if (user != null) {
            game.removePlayer(user);
            yield PlayerInvitedIntoGameState(game.chatId, event.triggeredBy);
          }
          break;
        case GameEventType.finishJoin:
          if (state is InvitingGameState && event.triggeredBy == game.admin) {
            yield SelectGameMasterState(game.chatId, event.triggeredBy);
          } else {
            yield GameState.WithError(state,
                messageForGroup:
                    'Пресечена незаконная попытка остановить набор игроков!');
          }
          break;
        case GameEventType.selectMaster:
          if (event.triggeredBy.isAdmin) {
            final master = event.additionalData as LitUser;
            master.isGameMaster = true;
            yield PlayerSortingState(game.chatId, event.triggeredBy, false);
          } else {
            yield GameState.WithError(state,
                messageForGroup:
                    'Данная операция доступна только администратору!');
          }
          break;

        case GameEventType.resetPlayersOrder:
          game.playersSorted.clear();
          game.playersSorted.add(LinkedUser(game.master));
          yield PlayerSortingState(game.chatId, event.triggeredBy, false);
          break;

        case GameEventType.sortPlayer:
          final player = event.additionalData as LitUser;
          game.playersSorted.add(LinkedUser(player));
          final isAllSorted = game.playersSorted.length == game.players.length;
          yield PlayerSortingState(game.chatId, event.triggeredBy, isAllSorted);
          break;

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
              game.chatId, event.triggeredBy, await game.trainingFlow);

          break;

        case GameEventType.trainingNextTurn:
          final trainingFlow = await game.trainingFlow;
          trainingFlow.nextTurn();
          yield TrainingFlowState(
              game.chatId, event.triggeredBy, await trainingFlow);

          break;

        case GameEventType.trainingEnd:
          TrainingFlow.stopGame(game.chatId);
          yield TrainingFlowState(
              game.chatId, event.triggeredBy, await game.trainingFlow);

          break;

        case GameEventType.gameFlowStart:
          final gameFlow = await game.gameFlowFactory();

          final cGeneric = gameFlow.getCard(CardType.generic);
          final cPlace = gameFlow.getCard(CardType.place);
          final cPerson = gameFlow.getCard(CardType.person);

          final selectedCards = <Card>[cGeneric, cPlace, cPerson];
          yield GameFlowMasterInitStory(
              game.chatId, event.triggeredBy, selectedCards);
          break;

        case GameEventType.gameFlowNextTurn:
          game.gameFlow.nextTurn();
          yield GameFlowPlayerSelectCard(game.chatId, event.triggeredBy);
          break;

        case GameEventType.gameFlowCardSelected:
          final type = CardType.generic.getTypeByName(event.additionalData);
          final card = game.gameFlow.getCard(type);
          yield GameFlowStoryTell(game.chatId, event.triggeredBy, card);
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
