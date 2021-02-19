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
  GameNotFoundException(message) : super(message);
}
