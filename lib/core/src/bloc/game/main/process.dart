import 'package:litgame_telegram/core/core.dart';
import 'package:litgame_telegram/core/src/bloc/game/game_flow/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/invite/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/kick/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/setup_game/process.dart';
import 'package:litgame_telegram/core/src/bloc/game/training/process.dart';

part 'events.dart';
part 'states.dart';

abstract class GameBaseProcess
    extends BusinessProcess<LitGameEvent, LitGameState> {
  GameBaseProcess(LitGameState initialState, this.game,
      {String? tag, GameBaseProcess? parent})
      : super(initialState, tag: tag, parent: parent);
  final LitGame game;
}

class MainProcess extends GameBaseProcess {
  MainProcess(LitGameState initialState, LitGame game, [String? tag])
      : super(initialState, game, tag: tag);

  InviteProcess get bpInvite => findSubProcess('invite') as InviteProcess;

  KickProcess get bpKick => findSubProcess('kick') as KickProcess;

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
    } else {
      return super.processEvent(event);
    }
  }
}

class BlocError {
  BlocError(this.event, {this.messageForUser, this.messageForGroup});

  LitGameEvent event;
  Object? messageForUser;
  Object? messageForGroup;
}
