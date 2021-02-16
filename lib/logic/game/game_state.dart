part of 'game_bloc.dart';

@immutable
abstract class GameState {}

class NoGame extends GameState {}

class InvitingGameState extends GameState {}

class SelectGameMasterState extends GameState {}

class SetPlayersOrderState extends GameState {}

class SelectCardCollectionState extends GameState {}

class TrainingFlowState extends GameState {}

class GameFlowState extends GameState {}
