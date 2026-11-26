
class MessageStore {
  static final Map<String, List<String>> _messages = {};

  static List<String> getMessages(String conversation) {
    return _messages.putIfAbsent(conversation, () => []);
  }

  static void sendMessage(
    String conversation,
    String message,
  ) {
    getMessages(conversation).add(message);
  }
}
