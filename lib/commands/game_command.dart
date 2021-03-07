// ignore_for_file: import_of_legacy_library_into_null_safe
part of commands;

mixin GameCmdMix on Command {
  late final TelegramEx telegram;
  late final Message message;

  void initTeledart(Message message, TelegramEx telegram) {
    this.message = message;
    this.telegram = telegram;
  }

  ArgParser getGameBaseParser() {
    var parser = ArgParser();
    parser.addOption('gci');
    return parser;
  }

  late GameBloc _logic;

  GameBloc get gameLogic => _logic;

  void initGameLogic(
      [GameEvent? initialEvent,
      Duration duration = const Duration(seconds: 5)]) {
    try {
      _logic = GameBloc(game.state);
    } catch (_) {
      _logic = GameBloc(NoGame(LitUser.byId(0)));
    }
    gameLogic.listen(_stateListener);
    if (initialEvent != null) {
      gameLogic.add(initialEvent);
    }
    Future.delayed(duration).then((_) {
      gameLogic.close();
    });
  }

  @protected
  void stateLogic(GameState state);

  void _stateListener(GameState state) {
    try {
      stateLogic(state);
      _catchStateErrors(state);
    } catch (exception) {
      print(exception);
    }
  }

  void _catchStateErrors(GameState state) {
    if (state.messageForGroup != null) {
      telegram.sendMessage(state.gameId, state.messageForGroup.toString());
    }
    if (state.messageForUser != null) {
      telegram.sendMessage(
          state.triggeredBy.chatId, state.messageForUser.toString());
    }
  }

  LitGame get game {
    var gameChatId = arguments?['gci'];
    if (arguments?['gci'] is String) {
      gameChatId = int.parse(arguments?['gci']);
    }
    if (gameChatId == null && message.chat.id < 0) {
      gameChatId = message.chat.id;
    }
    return LitGame.find(gameChatId);
  }

  int? get gameChatId => (arguments?['gci'] is String)
      ? int.parse(arguments?['gci'])
      : arguments?['gci'];

  @protected
  void checkGameChat(Message message) {
    if (message.chat.id > 0) {
      throw 'Эту команду надо не в личке запускать, а в чате с игроками ;-)';
    }
  }
}

abstract class GameCommand extends Command
    with GameCmdMix
    implements GameCmdMix {}

abstract class ComplexGameCommand extends ComplexCommand
    with GameCmdMix
    implements GameCmdMix {
  @override
  String buildAction(String actionName, [Map<String, String>? parameters]) {
    parameters ??= {};
    if (parameters['gci'] == null) {
      parameters['gci'] = gameChatId.toString();
    }
    return super.buildAction(actionName, parameters);
  }
}
