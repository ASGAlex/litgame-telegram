part of 'game_bloc.dart';

@immutable
abstract class GameState {
  GameState(this.gameId);

  final int gameId;

  LitGame? get game => LitGame.find(gameId);
}

class NoGame extends GameState {
  NoGame() : super(0);
}

class InvitingGameState extends GameState {
  InvitingGameState(int gameId, [this.lastInviteResult, this.lastInvitedUser])
      : super(gameId);
  final bool? lastInviteResult;
  final LitUser? lastInvitedUser;
}

// class SelectGameMasterState extends GameState {}
//
// class SetPlayersOrderState extends GameState {}
//
// class SelectCardCollectionState extends GameState {}
//
// class TrainingFlowState extends GameState {}
//
// class GameFlowState extends GameState {}
