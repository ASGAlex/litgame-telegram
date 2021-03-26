part of 'process.dart';

class JoinGameEvent extends LitGameEvent {
  JoinGameEvent(LitUser triggeredBy, this.userToBeInvited) : super(triggeredBy);

  final LitUser userToBeInvited;

  JoinGameEvent.empty()
      : userToBeInvited = LitUser.byId(0),
        super(LitUser.byId(0));

  @override
  Type get type => JoinGameEvent.empty().runtimeType;
}
