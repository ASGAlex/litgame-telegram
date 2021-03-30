import 'package:litgame_telegram/core/core.dart';

part 'events.dart';
part 'states.dart';

class MainProcess extends GameBaseProcess {
  MainProcess(LitGameState initialState, LitGame game, [String? tag])
      : super(initialState, game, tag: tag);

  InviteProcess get bpInvite => findSubProcess('invite') as InviteProcess;

  KickProcess get bpKick => findSubProcess('kick') as KickProcess;

  @override
  List get acceptedEvents => [MainProcessEvent.gameFinished];

  @override
  LitGameState? processEvent(LitGameEvent event) {
    if (event is GameFinishedEvent) {
      final player = game.players[event.triggeredBy.chatId];
      if ((player != null && player.isAdmin) || (game.players.isEmpty)) {
        LitGame.stopGame(game.id);
        GameFlow.stopGame(game.id);
        TrainingFlow.stopGame(game.id);
        return NoGameState();
      } else {
        addError(BlocError(event,
            messageForGroup:
                'У тебя нет власти надо мной! Пусть админ игры её остановит.'));
      }
    }
  }
}
