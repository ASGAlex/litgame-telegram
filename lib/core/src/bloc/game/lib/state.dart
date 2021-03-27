import 'package:litgame_telegram/core/core.dart';

import 'process.dart';

abstract class LitGameState<Process extends GameBaseProcess>
    extends BPState<LitGameState, LitGameEvent, Process> {
  LitGameState();
}
