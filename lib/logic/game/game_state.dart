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

class NoGame extends GameState {
  NoGame(LitUser triggeredBy) : super(0, triggeredBy);
}

class InvitingGameState extends GameState {
  InvitingGameState(int gameId, LitUser triggeredBy,
      [this.lastInviteResult, this.lastInvitedUser])
      : super(gameId, triggeredBy);
  final bool? lastInviteResult;
  final LitUser? lastInvitedUser;
}

class SelectGameMasterState extends GameState {
  SelectGameMasterState(int gameId, LitUser triggeredBy)
      : super(gameId, triggeredBy);
}

class SetPlayersOrderState extends GameState {
  SetPlayersOrderState(int gameId, LitUser triggeredBy, this.sorted)
      : super(gameId, triggeredBy);
  final bool sorted;
}
//
// class SelectCardCollectionState extends GameState {}
//
// class TrainingFlowState extends GameState {}
//
// class GameFlowState extends GameState {}
