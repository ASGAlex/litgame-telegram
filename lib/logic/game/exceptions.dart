part of 'game_bloc.dart';

abstract class GameBaseException implements Exception {
  GameBaseException(this.message);

  final dynamic message;

  @override
  String toString() {
    Object? message = this.message;
    return 'Exception: $message';
  }
}

class GameNotFoundException extends GameBaseException {
  GameNotFoundException(int gameId) : super('Game $gameId not found!');
}

class GameNotLaunchedException extends GameBaseException {
  GameNotLaunchedException([int? gameId])
      : super('Game ' +
            (gameId != null ? 'with id ${gameId}' : '') +
            ' not launched!');
}

class GameLaunchedException extends GameBaseException {
  GameLaunchedException([int? gameId])
      : super('Game ' +
            (gameId != null ? 'with id ${gameId}' : '') +
            ' already launched!');
}
