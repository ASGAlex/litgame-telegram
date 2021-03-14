import 'package:bloc/bloc.dart';
import 'package:litgame_telegram/logic/game/game_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:teledart/model.dart';
import 'package:teledart_app/teledart_app.dart';

import 'commands/commands.dart';
import 'models/game/game.dart';

class GameEventObserver extends BlocObserver with MessageDeleter {
  GameEventObserver(this.telegram);

  final TelegramEx telegram;

  @override
  void onTransition(Bloc bloc, Transition transition) async {
    bloc as GameBloc;
    final event = transition.event as GameEvent;
    _handleStateWithError(bloc, transition.nextState as GameState);
    switch (transition.nextState.runtimeType) {
      case InvitingGameState:
        if (transition.currentState.runtimeType != NoGameState) {
          unawaited(telegram
              .sendMessage(
                  bloc.game.id,
                  '=========================================\r\n'
                  'Начинаем новую игру! \r\n'
                  'ВНИМАНИЕ, с кем ещё не общались - напишите мне в личку, чтобы я тоже мог вам отправлять сообщения.\r\n'
                  'У вас на планете дискриминация роботов, поэтому сам я вам просто так написать не смогу :-( \r\n'
                  '\r\n'
                  'Кто хочет поучаствовать?',
                  reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                    [
                      InlineKeyboardButton(
                          text: StartGameCmd.BTN_YES, callback_data: '/joinme'),
                      InlineKeyboardButton(
                          text: StartGameCmd.BTN_NO, callback_data: '/kickme')
                    ]
                  ]))
              .then((msg) {
            scheduleMessageDelete(msg.chat.id, msg.message_id);
          }));
        }
        break;
      case NoGameState:
        unawaited(telegram.sendMessage(bloc.game.id, 'Всё, наигрались!',
            reply_markup: ReplyKeyboardRemove(remove_keyboard: true)));
        deleteScheduledMessages(telegram);
        break;
      case PlayerInvitedIntoGameState:
        final cmd = JoinMeCmd();
        final event = transition.event as GameEvent;
        if (event.type == GameEventType.kickFromGame) {
          cmd.sendStatisticsToAdmin(bloc.game, telegram, bloc.game.id);
        } else {
          final state = bloc.state as PlayerInvitedIntoGameState;
          final user = state.lastInvitedUser;
          if (user == null) {
            throw 'Попытка инвайтить незнаю кого';
          }
          cmd.sendChatIdRequest(bloc.game, user, telegram);

          if (state.lastInviteResult == true) {
            cmd.sendStatisticsToAdmin(state.game, telegram, bloc.game.id);
          } else {
            final existingGame = LitGame.findGameOfPlayer(user.chatId);
            if (existingGame != state.game) {
              unawaited(telegram.sendMessage(
                  bloc.game.id,
                  user.nickname +
                      ' играет в какой-то другой игре. Надо её сначала завершить или выйти.'));
              unawaited(telegram.getChat(existingGame?.id).then((chat) {
                var chatName = chat.title ?? chat.id.toString();
                telegram.sendMessage(
                    user.chatId,
                    'Чтобы начать новую игру, нужно завершить текущую в чате "' +
                        chatName +
                        '"');
              }));
            }
          }
        }
        break;
      case SelectGameMasterState:
        deleteScheduledMessages(telegram);
        final keyboard = <List<InlineKeyboardButton>>[];
        bloc.game.players.values.forEach((player) {
          var text = player.nickname + ' (' + player.fullName + ')';
          if (player.isAdmin) {
            text += '(admin)';
          }
          if (player.isGameMaster) {
            text += '(master)';
          }

          keyboard.add([
            InlineKeyboardButton(
                text: text,
                callback_data: SetMasterCmd().buildCommandCall({
                  'gci': bloc.game.id.toString(),
                  'userId': player.telegramUser.id.toString()
                }))
          ]);
        });

        unawaited(telegram
            .sendMessage(bloc.game.admin.chatId, 'Выберите мастера игры: ',
                reply_markup: InlineKeyboardMarkup(inline_keyboard: keyboard))
            .then((msg) {
          scheduleMessageDelete(msg.chat.id, msg.message_id);
        }));
        break;

      case PlayerSortingState:
        final state = transition.nextState as PlayerSortingState;
        final cmd = Command.withArguments(() => SetOrderCmd(),
            {'gci': bloc.game.id.toString(), 'reset': ''}) as SetOrderCmd;
        if (state.sorted) {
          unawaited(telegram
              .sendMessage(bloc.game.admin.chatId,
                  'Игроки отсортированы:\r\n' + cmd.getSortedUsersListText(),
                  reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                    [
                      InlineKeyboardButton(
                          text: 'Играем!',
                          callback_data: SetCollectionCmd().buildAction(
                              'list', {'gci': bloc.game.id.toString()})),
                      InlineKeyboardButton(
                          text: 'Отсортировать заново',
                          callback_data: cmd.buildCommandCall(
                              {'gci': bloc.game.id.toString(), 'reset': ''}))
                    ]
                  ]))
              .then((msg) {
            scheduleMessageDelete(msg.chat.id, msg.message_id);
          }));
        } else {
          unawaited(telegram
              .sendMessage(
                  bloc.game.admin.chatId,
                  'В каком порядке будут ходить игроки:\r\n' +
                      cmd.getSortedUsersListText(),
                  reply_markup: InlineKeyboardMarkup(
                      inline_keyboard: cmd.getSortButtons()))
              .then((msg) {
            scheduleMessageDelete(msg.chat.id, msg.message_id);
          }));
        }
        break;

      case TrainingFlowState:
        if (event.type == GameEventType.trainingStart) {
          const litMsg = 'Небольшая разминка!\r\n'
              'Сейчас каждому из игроков будет выдаваться случайная карта из колоды,'
              'и нужно будет по ней рассказать что-то, что связано с миром/темой, '
              'на которую вы собираетесь играть.\r\n'
              'Это позволит немного разогреть мозги, вспомнить забытые факты и "прокачать"'
              'менее подготовленных к игре товарищей.\r\n';
          unawaited(telegram.sendMessage(bloc.game.id, litMsg));
          final cmd = TrainingFlowCmd();
          final msgToAdminIsCopied = cmd.copyChat((chatId, completer) {
            final future = telegram.sendMessage(chatId, litMsg);
            if (chatId == bloc.game.master.chatId) {
              future.then((value) {
                completer.complete();
              });
            }
          });

          unawaited(msgToAdminIsCopied.then((value) {
            telegram.sendMessage(bloc.game.master.chatId,
                'Когда решишь, что разминки хватит - жми сюда!',
                reply_markup: InlineKeyboardMarkup(inline_keyboard: [
                  [
                    InlineKeyboardButton(
                        text: 'Завершить разминку',
                        callback_data: cmd.buildAction('end'))
                  ]
                ]));
            bloc.addEvent(
                GameEventType.trainingNextTurn, event.triggeredBy, true);
          }));
        } else {
          final cmd = TrainingFlowCmd();
          cmd.sendNextTurnToChat(bloc.game, telegram);
        }
        break;

      case TrainingEndState:
        final cmd = TrainingFlowCmd();
        await cmd.sendTrainingEndToChat(bloc.game, telegram);
        bloc.addEvent(GameEventType.gameFlowStart, event.triggeredBy);
        break;

      case GameFlowMasterInitStory:
        final flow = await bloc.game.gameFlowFactory();
        final cmd = ComplexCommand.withAction(() => GameFlowCmd(), 'start', {
          'gci': bloc.game.id.toString(),
          'cid': flow.collectionId
        }) as GameFlowCmd;
        cmd.onGameStart(Message(), telegram);
        break;

      case GameFlowPlayerSelectCard:
        final cmd =
            ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
          'gci': bloc.game.id.toString(),
        }) as GameFlowCmd;
        cmd.printCardSelectionMessages();
        break;

      case GameFlowStoryTell:
        final cmd =
            ComplexCommand.withAction(() => GameFlowCmd(), 'onNextTurn', {
          'gci': bloc.game.id.toString(),
        }) as GameFlowCmd;
        final state = transition.nextState as GameFlowStoryTell;
        cmd.printStoryTellMode(state.selectedCard);
        break;
    }

    super.onTransition(bloc, transition);
  }

  void _handleStateWithError(GameBloc bloc, GameState state) {
    if (state.messageForGroup != null) {
      telegram.sendMessage(state.game.id, state.messageForGroup.toString());
    }
    if (state.messageForUser != null) {
      telegram.sendMessage(
          state.triggeredBy.chatId, state.messageForUser.toString());
    }
  }
}
