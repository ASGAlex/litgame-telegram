part of 'game_bloc.dart';

abstract class GameState extends BPState<GameEvent> {
  GameState(this._game);

  final LitGame _game;

  LitGame get game => _game;
}

class BlocError {
  BlocError({this.messageForUser, this.messageForGroup});

  Object? messageForUser;
  Object? messageForGroup;
}

class PlayerKickedDuringGame extends InvitingGameState {
  PlayerKickedDuringGame(int gameId, LitUser triggeredBy,
      bool lastOperationSuccess, LitUser lastProcessedUser)
      : super(gameId, triggeredBy, lastOperationSuccess, lastProcessedUser);
}

class SelectAdminState extends GameState {
  SelectAdminState(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);
}

class SelectGameMasterState extends GameState {
  SelectGameMasterState(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);
}

class PlayerSortingState extends GameState {
  PlayerSortingState(int gameId, LitUser triggeredBy, this.sorted)
      : super(gameId, triggeredBy);
  final bool sorted;
}

class TrainingFlowState extends GameState {
  TrainingFlowState(int gameId, LitUser triggeredBy, this.flow)
      : super(gameId, triggeredBy);
  final TrainingFlow flow;
}

class GameFlowMasterInitStoryState extends GameState {
  GameFlowMasterInitStoryState(
      int gameId, LitUser triggeredBy, this.selectedCards)
      : super(gameId, triggeredBy);
  final List<Card> selectedCards;
}

class GameFlowPlayerSelectCardState extends GameState {
  GameFlowPlayerSelectCardState(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);
}

class GameFlowStoryTellState extends GameState {
  GameFlowStoryTellState(int gameId, LitUser triggeredBy, this.selectedCard)
      : super(gameId, triggeredBy);
  final Card selectedCard;
}
