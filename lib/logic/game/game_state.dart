part of 'game_bloc.dart';

abstract class GameState {
  GameState(this.gameId, this.triggeredBy);

  final int gameId;

  LitGame get game => LitGame.find(gameId);
  final LitUser triggeredBy;

  factory GameState.WithError(GameState object,
      {Object? messageForUser, Object? messageForGroup}) {
    object.messageForUser = messageForUser;
    object.messageForGroup = messageForGroup;
    return object;
  }

  Object? messageForUser;
  Object? messageForGroup;
}

class NoGameState extends GameState {
  NoGameState(LitUser triggeredBy) : super(0, triggeredBy);
}

class InvitingGameState extends GameState {
  InvitingGameState(int gameId, LitUser triggeredBy,
      [this.lastInviteResult, this.lastInvitedUser])
      : super(gameId, triggeredBy);
  final bool? lastInviteResult;
  final LitUser? lastInvitedUser;
}

class PlayerInvitedIntoGameState extends InvitingGameState {
  PlayerInvitedIntoGameState(int gameId, LitUser triggeredBy)
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

class TrainingEndState extends GameState {
  TrainingEndState(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);
}

class GameFlowMasterInitStory extends GameState {
  GameFlowMasterInitStory(int gameId, LitUser triggeredBy, this.selectedCards)
      : super(gameId, triggeredBy);
  List<Card> selectedCards;
}

class GameFlowPlayerSelectCard extends GameState {
  GameFlowPlayerSelectCard(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);
}

class GameFlowStoryTell extends GameState {
  GameFlowStoryTell(int gameId, LitUser triggeredBy, this.selectedCard)
      : super(gameId, triggeredBy);
  Card selectedCard;
}

class GFMaster3CardStoryTellState extends GameState {
  GFMaster3CardStoryTellState(
      int gameId, LitUser triggeredBy, this.flow, this.selectedCards)
      : super(gameId, triggeredBy);
  final GameFlow flow;
  final List<Card> selectedCards;
}

class GFStoryTellState extends GFMaster3CardStoryTellState {
  GFStoryTellState(
      int gameId, LitUser triggeredBy, GameFlow flow, List<Card> selectedCards)
      : super(gameId, triggeredBy, flow, selectedCards);
}

class GFPlayerCardSelectionState extends GFMaster3CardStoryTellState {
  GFPlayerCardSelectionState(
    int gameId,
    LitUser triggeredBy,
    GameFlow flow,
  ) : super(gameId, triggeredBy, flow, const []);
}
