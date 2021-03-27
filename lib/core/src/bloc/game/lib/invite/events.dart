part of 'process.dart';

enum JoinEvent { join }

class JoinGameEvent extends LitGameEvent {
  JoinGameEvent(LitUser triggeredBy, this.userToBeInvited) : super(triggeredBy);

  final LitUser userToBeInvited;

  @override
  dynamic get type => JoinEvent.join;
}
