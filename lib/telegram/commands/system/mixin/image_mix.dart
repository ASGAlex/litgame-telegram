part of commands;

mixin ImageSender on ComplexCommand {
  @protected
  Future sendImage(int chatId, String url, String caption,
      [bool clear = true]) {
    return telegram.sendPhoto(chatId, url, caption: caption).then((msg) {
      if (clear) {
        scheduleMessageDelete(msg.chat.id, msg.message_id);
      }
    });
  }
}
