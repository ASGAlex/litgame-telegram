// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:litgame_telegram/commands/complex_command.dart';
import 'package:litgame_telegram/commands/middleware.dart';
import 'package:litgame_telegram/models/game/game.dart';
import 'package:litgame_telegram/models/game/user.dart';
import 'package:litgame_telegram/telegram.dart';
import 'package:teledart/model.dart';
import 'package:teledart/src/telegram/model.dart';

class HelpCmd extends ComplexCommand with Middleware {
  @override
  bool get system => false;

  @override
  Map<String, CmdAction> get actionMap => {
        'firstRun': onFirstRun,
        'aboutGame': onAboutGame,
        'forMaster': onForMaster,
        'forPlayer': onForPlayer
      };

  @override
  String get name => 'help';

  void onFirstRun(Message message, LitTelegram telegram) {
    telegram
        .sendMessage(message.chat.id, 'Я запомнил тебя! Обещаю не спамить :-)')
        .then((value) {
      _sendHelpInitialMessage();
    });
  }

  void onForPlayer(Message message, LitTelegram telegram) {
    const text = 'Вас позвали в игру, а вы не знаете, что делать? Или просто имеется '
        'неимоверная тяга к знаниям? Что ж, рассказываю. \r\n'
        '\r\n'
        'Начинает игру мастер игры. Ему выпадает случайным образом три карты, по которым он '
        'должен составить завязку истории. После игромастера ничинают ходить другие игроки'
        'в заданном админом игры порядке. \r\n'
        'Когда наступит твой ход, я напишу тебе в личку, '
        'предложу вырать карту из одной из трёх категорий. Отменить свой выбор или выбрать '
        'несколько карт подряд нельзя! Выбранная карта будет показана и тебе в личных '
        'сообщениях, и другим игрокам в чате игры. С этого момента историю нужно продолжать '
        'тебе :-) Время не ограничено, но затягивать свой рассказ сильно больше, '
        'чем на несколько минут, как-то нехорошо...\r\n'
        'Когда закончишь свою часть истории, загляни ко мне в личку, там будет кнопка'
        '"Завершить ход". Её надо нажать, и тогда уже следующий игрок будет тянуть '
        'карту...\r\n'
        '\r\n'
        'В целом, как-то так. Если остались ещё вопросы - пытай своего игромастера, '
        'этот чувак должен быть в курсе, что да как ;-)';
    telegram.sendMessage(message.chat.id, text.escapeMarkdownV2(),
        parse_mode: 'MarkdownV2');
  }

  void onForMaster(Message message, LitTelegram telegram) {
    const text = 'Начать новую игру можно вот так: \r\n'
        '1. Собрать всех участников игры в одном чате.\r\n'
        '2. Добавить бота (меня!) в этот чат.'
        '3. В чате набрать команду /startgame - она появится в списке подсказок.\r\n'
        '4. В общем чате появится кнопка подключения к игре. А в чате с ботом (со мной!)'
        'будут появляться уведомления о составе игроков. Когда все участники подключатся к игре,'
        'нужно будет нажать кнопку "Завершить набор игроков", после чего новые игроки уже '
        'не смогут подключиться.\r\n'
        '5. Следующим шагом я спрошу тебя, которого из игроков нужно будет сделать '
        'мастером. Выбирай из списка себя или кого-то другого, кто будет вести игру.\r\n'
        '6. Далее нужно будет выбрать порядок, в котором игроки будут ходить. Мастер '
        'всегда ходит первым, его очерёдность изменить не получится.\r\n'
        '7. После сортировки игроков мастеру будет предложено выбрать набор карт для игры - '
        'если, конечно, на сервер их загрузили больше одного.\r\n'
        '8. И после этого, наконец, начнётся игра. Первым ходит всегда мастер, и ему '
        'предстоит начать сразу с трёх карт. Все последующие ходы любому игроку доступна '
        'на выбор только одна карта за ход.\r\n'
        '9. Когда закончите игру, не забудь запустить в общем чате команду /endgame. Не '
        'остановив старую игру, новую начать не получится. Остановить её может только тот, '
        'кто запускал. '
        '\r\n'
        'Надеюсь, у меня получилось нормально объяснить :-)';
    telegram.sendMessage(message.chat.id, text.escapeMarkdownV2(),
        parse_mode: 'MarkdownV2');
  }

  void onAboutGame(Message message, LitTelegram telegram) {
    const text =
        '*Суть и задача игры* - составить вместе с друзьями произвольную историю '
        'на определённую тему. И, конечно, получить удовольствие и от процесса и от '
        'результата :-) \r\n\r\n'
        '*Правила игры:*\r\n'
        ' - Игроки ходят по очереди. Каждый игрок в свой ход тянет карту из одной из трёх'
        'колод на выбор и рассказывает свою часть истории, руководствуясь той картой, '
        'которая ему выпала. \r\n\r\n'
        ' - Во время хода игрока никто не имеет права его поправлять или перебивать, он '
        'полностью свободен в трактовке смысла карты и составлении своей части истории, '
        'хотя и должен опираться на здравый смысл, рассказанный ранее сюжет и общие '
        'договорённости.\r\n\r\n'
        ' - Перед началом игры рекомендуется совместно решить, к какому жанру, стилю и '
        'вселенной будет относиться повествование.\r\n\r\n'
        '\r\n'
        '*Виды карт.* Карты в игре есть трёх типов:\r\n'
        ' - Место - предполагает, что действие сюжета должно быть перенесено в '
        'указанное на карте место (в прямом или переносном смысле)\r\n'
        ' - Персонаж - вытянувший эту карту игрок должен ввести в повествование персонажа'
        '(в прямом или переносном смысле), указанного на карте. \r\n'
        ' - Общая - эти карты задают тему для всех остальных событий/явлений, которые'
        'должны произойти в игровом мире в ход вытянувшего их игрока. \r\n'
        '\r\n'
        'НО не относитесь к этому чересчур серьёзно! Помните - это всего лишь игра ;-)';
    telegram.sendMessage(message.chat.id, text.escapeMarkdownV2(),
        parse_mode: 'MarkdownV2');
  }

  @override
  void onNoAction(Message message, LitTelegram telegram) {
    _sendHelpInitialMessage();
  }

  void _sendHelpInitialMessage() {
    telegram.sendMessage(
        message.chat.id, 'Возникли вопросы? Вот что я могу о себе рассказать: ',
        reply_markup: InlineKeyboardMarkup(inline_keyboard: [
          [
            InlineKeyboardButton(
                text: 'Что такое литигра?', callback_data: buildAction('aboutGame'))
          ],
          [
            InlineKeyboardButton(
                text: 'Я игромастер. Как мне создать и вести игру?',
                callback_data: buildAction('forMaster'))
          ],
          [
            InlineKeyboardButton(
                text: 'Я простой игрок. Как мне играть?',
                callback_data: buildAction('forPlayer'))
          ],
        ]));
  }

  /// Юзер написал в личку, просто так или чтобы бот получил айди чата.
  ///
  @override
  void handle(Update data, LitTelegram telegram) {
    if (data.message?.chat.type == 'private') {
      final user = LitUser(data.message.from);
      user.registrationChecked.then((registered) {
        if (!registered) {
          user.save();
          run(data.message, telegram);
        }
        _copyPMMessagesToGameChat(data.message, telegram);
      });
    }
  }

  void _copyPMMessagesToGameChat(Message message, LitTelegram telegram) {
    final player = LitGame.findPlayerInExistingGames(message.chat.id);
    if (player != null && player.isCopyChatSet) {
      final gameChatId = player.currentGame?.chatId;
      if (gameChatId == null) {
        throw 'Player is in game, but currentGame.chatId is null!';
      }
      final text = 'Игрок ' +
          player.nickname +
          ' (' +
          player.fullName +
          ') пишет: \r\n' +
          message.text;
      telegram.sendMessage(gameChatId, text);
    }
  }
}
