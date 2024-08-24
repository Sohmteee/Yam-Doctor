import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

void handleSendPressed(types.PartialText message) {
  final textMessage = types.TextMessage(
    author: _user,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    id: const Uuid().v4(),
    text: message.text,
  );

  addMessage(textMessage);
}
